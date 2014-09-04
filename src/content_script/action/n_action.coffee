# Normal actions

N_Action =
  log: ->
    console.log @state

  # ------------------------------------------------------------
  # App-wise actions
  # ------------------------------------------------------------

  hide: ->
    @setState { animation: 'fadeOutUp' }

    timeOutFunc = =>
      @setState { visible: no }
      @callAction('n_reset')

    setTimeout(timeOutFunc, 200)

  show: ->
    @setState
      visible: yes
      animation: 'fadeInDown'

  toggle: ->
    if @state.visible
      @callAction('n_hide')
    else
      @callAction('n_show')

  # ------------------------------------------------------------

  reset: ->
    @setDeepState
      input: ''

      mode: 'query'
      specialMode: 'no'

      animation: 'fadeInDown'
      nodeAnimation: {}

      nodeArray: []
      selectedArray: []

      useSuggestedTag: yes

      currentNodeIndex: 0
      currentPageIndex: 0

      cache:
        input: ''
        selectedArray: []

  clearInput: ->
    if @state.mode is 'query'
      @setState
        input: ''

        nodeArray: []
        selectedArray: []

        currentNodeIndex: 0
        currentPageIndex: 0
    else
      @setState { input: ':' }

  # ------------------------------------------------------------

  nextMode: ->
    if @state.mode is 'query'
      @setState { mode: 'fast' }
    else if @state.mode is 'fast'
      @setDeepState
        mode: 'command'
        input: ':'
        cache:
          input: @state.input
    else
      @setDeepState
        mode: 'query'
        input: @state.cache.input
        cache:
          input: ''

  prevMode: ->
    if @state.mode is 'fast'
      @setState { mode: 'query' }
    else if @state.mode is 'command'
      @setState
        mode: 'fast'
        input: @state.cache.input
        cache:
          input: ''
    else
      @setDeepState
        mode: 'command'
        input: ':'
        cache:
          input: @state.input

  # ------------------------------------------------------------
  # Movements
  # ------------------------------------------------------------

  up: ->
    if @state.nodeArray.length is 0
      return

    MAX = @state.option.MAX_SUGGESTION_NUM
    if @state.currentNodeIndex is 0
      if @state.currentPageIndex is 0
        currentNodeFullIndex = @state.nodeArray.length - 1
        @setState
          currentNodeIndex:
            currentNodeFullIndex % MAX
          currentPageIndex:
            Math.floor( currentNodeFullIndex / MAX)
      else
        @callAction('n_pageUp')
        @setState { currentNodeIndex: MAX - 1 }
    else
      currentNodeIndex = @state.currentNodeIndex - 1
      @setState { currentNodeIndex }

  down: ->
    if @state.nodeArray.length is 0
      return

    MAX = @state.option.MAX_SUGGESTION_NUM
    if @getCurrentNodeFullIndex() is @state.nodeArray.length - 1
      @setState
        currentNodeIndex: 0
        currentPageIndex: 0
    else
      if @state.currentNodeIndex isnt MAX - 1
        @setState { currentNodeIndex: @state.currentNodeIndex + 1 }
      else
        @setState
          currentNodeIndex: 0
          currentPageIndex: @state.currentPageIndex + 1

  # ------------------------------------------------------------

  pageUp: ->
    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    currentPageLastNodeIndex =
      (@state.currentPageIndex + 1) * @state.option.MAX_SUGGESTION_NUM
    if currentPageLastNodeIndex < @state.nodeArray.length
      @setState
        currentPageIndex: @state.currentPageIndex + 1
        currentNodeIndex: 0
      
  # ------------------------------------------------------------
  # Selection
  # ------------------------------------------------------------

  select: ->
    unless _.contains(@state.selectedArray, @getCurrentNodeFullIndex())
      selectedArray =
        _.union(@state.selectedArray, [@getCurrentNodeFullIndex()])
      @setState { selectedArray }

  unselect: ->
    if _.contains(@state.selectedArray, @getCurrentNodeFullIndex())
      selectedArray =
        _.without(@state.selectedArray, @getCurrentNodeFullIndex())
      @setState { selectedArray }

  # ------------------------------------------------------------

  selectAllInCurrentPage: ->
    newlySelected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.union(@state.selectedArray, newlySelected)
    @setState { selectedArray }

  selectAll: ->
    @setState { selectedArray: [0...@state.nodeArray.length] }

  unselectAllInCurrentPage: ->
    newlyUnselected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.difference(@state.selectedArray, newlyUnselected)
    @setState { selectedArray }

  unselectAll: ->
    @setState { selectedArray: [] }

  toggleAllSelectionInCurrentPage: ->
    currentPageNodeIndexArray = []
    if _.every([@getNodeIndexStart()...@getNodeIndexEnd()],
        (index) => _.contains(@state.selectedArray, index))
      @callAction('n_unselectAllInCurrentPage')
    else
      @callAction('n_selectAllInCurrentPage')

  toggleAll: ->
    if @state.selectedArray.length is @state.nodeArray.length
      @callAction('n_unselectAll')
    else
      @callAction('n_selectAll')

  # ------------------------------------------------------------
  # Opening bookmarks
  # ------------------------------------------------------------
  
  openHelper: (option, newWindow, needHide) ->
    message =
      request: if newWindow then 'openInNewWindow' else 'open'
      option: option

    if _.isEmpty(@state.selectedArray)
      message['node'] = @getCurrentNode()
    else
      message['nodeArray'] = @getSelectedNodeArray()

    Message.postMessage(message)
    if needHide then @callAction('n_hide')

  open: ->
    @callAction('n_openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('n_openHelper', [{ active:    no  }, no , no ])

  openInNewWindow: ->
    @callAction('n_openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWindow: ->
    @callAction('n_openHelper', [{ incognito: yes }, yes, yes])

  # ------------------------------------------------------------
  # Remove bookmarks
  # ------------------------------------------------------------
    
  remove: ->
    if @state.nodeArray.length isnt 0
      # index within all nodeArray, not within current page nodes
      currentNodeFullIndex = @getCurrentNodeFullIndex()
      nodeAnimation = {}
      nodeAnimation[currentNodeFullIndex] = 'fadeOutRight'
      @setState { nodeAnimation }

      # remove bookmark from screen using animation
      timeOutFunc = =>
        nodeArray = @state.nodeArray
        nodeArray = _.without(nodeArray, nodeArray[currentNodeFullIndex])

        # if the current selected node is the last one
        # let it still point to the last node after one node is removed
        if currentNodeFullIndex is nodeArray.length
          if @state.currentNodeIndex is 0
            currentNodeIndex = @state.option.MAX_SUGGESTION_NUM - 1
            currentPageIndex = @state.currentPageIndex - 1
          else
            currentNodeIndex = @state.currentNodeIndex - 1
            currentPageIndex = @state.currentPageIndex

          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

            currentNodeIndex: currentNodeIndex
            currentPageIndex: currentPageIndex
        else
          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

        @callAction('n_reset') if _.isEmpty(@state.nodeArray)

      setTimeout(timeOutFunc, 350)

      # really remove the bookmark in DB
      Message.postMessage
        request: 'removeBookmark'
        id: @getCurrentNode().id

  # ------------------------------------------------------------
  # Other actions
  # ------------------------------------------------------------

  lastWindow: (option) ->
    Message.postMessage
      request: 'lastWindow'
    @callAction('n_hide')

  lastWindowInBackground: (option) ->
    Message.postMessage
      request: 'lastWindowInBackground'
    @callAction('n_clearInput')

  lastWindowInNewWindow: (option) ->
    Message.postMessage
      request: 'lastWindowInNewWindow'
    @callAction('n_hide')

  lastWindowInNewIncognitoWindow: (option) ->
    Message.postMessage
      request: 'lastWindowInNewIncognitoWindow'
    @callAction('n_hide')

  # ------------------------------------------------------------
