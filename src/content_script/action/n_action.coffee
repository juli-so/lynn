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
    @setState
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

    @callAction('n_clearCache')

  clearInput: ->
    if @state.mode is 'query'
      @setState
        input: ''

        nodeArray: []
        selectedArray: []

        currentNodeIndex: 0
        currentPageIndex: 0
    else if @state.mode is 'fast'
      @setState { mode: 'query' }
      @callAction('n_clearInput')
    else
      @setState { input: ':' }

  # ------------------------------------------------------------

  nextMode: ->
    if @state.mode is 'query'
      @setState { mode: 'fast' }

    else if @state.mode is 'fast'
      @setState { mode: 'command' }

      if @state.cache.input is ''
        @callAction('n_storeCache')
        @setState { input: ':' }
      else
        @callAction('n_storeAndRecoverFromCache')

    else
      @setState { mode: 'query' }

      if @state.input is ':'
        @callAction('n_recoverFromCache')
        @callAction('n_clearCache')
      else
        @callAction('n_storeAndRecoverFromCache')

  prevMode: ->
    if @state.mode is 'fast'
      @setState { mode: 'query' }

    else if @state.mode is 'command'
      @setState { mode: 'fast' }

      if @state.input is ':'
        @callAction('n_recoverFromCache')
        @callAction('n_clearCache')
      else
        @callAction('n_storeAndRecoverFromCache')

    else
      @setState { mode: 'command' }

      if @state.cache.input is ''
        @callAction('n_storeCache')
        @setState { input: ':' }
      else
        @callAction('n_storeAndRecoverFromCache')

  goQueryMode: ->
    @setState
      input: ''
      mode: 'query'

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
  # Insertion
  # ------------------------------------------------------------

  insert: ->
    @setState
      mode: 'query'

  insertBefore: ->
    @setState
      mode: 'query'
    @callAction('n_setCaretToStart')

  # ------------------------------------------------------------
  # Opening bookmarks
  # ------------------------------------------------------------
  
  openHelper: (option, newWindow, needHide, nodeArray = null) ->
    message =
      request: if newWindow then 'openInNewWindow' else 'open'
      option: option

    if _.isNull(nodeArray)
      if @hasNoSelection()
        message['node'] = @getCurrentNode()
      else
        message['nodeArray'] = @getSelectedNodeArray()
    else
      message['nodeArray'] = nodeArray

    Message.postMessage(message)

    if needHide
      @callAction('n_hide')
    else
      @setState { selectedArray: [] }

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
      nodeArray = @state.nodeArray
      selectedArray = @state.selectedArray
      MAX = @state.option.MAX_SUGGESTION_NUM

      if @hasNoSelection()
        # index within all nodeArray, not within current page nodes
        currentNodeFullIndex = @getCurrentNodeFullIndex()
        nodeAnimation = {}
        nodeAnimation[currentNodeFullIndex] = 'fadeOutRight'
        @setState { nodeAnimation }

        # Remove the bookmark in DB
        Message.postMessage
          request: 'removeBookmark'
          id: @getCurrentNode().id

        # Remove bookmark from screen using animation
        timeOutFunc = =>
          nodeArray = _.without(nodeArray, nodeArray[currentNodeFullIndex])

          # if the current selected node is the last one
          # let it still point to the last node after one node is removed
          if currentNodeFullIndex is nodeArray.length
            if @state.currentNodeIndex is 0
              currentNodeIndex = MAX - 1
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

          # Return to query mode if there is no search results 
          @setState({ mode: 'query' }) if _.isEmpty(@state.nodeArray)

        setTimeout(timeOutFunc, 350)

      else # HasSelection
        nodeAnimation = {}
        _.forEach selectedArray, (nodeIndex) ->
          nodeAnimation[nodeIndex] = 'fadeOutRight'
        @setState { nodeAnimation }

        # Remove the bookmark in DB
        idArray = _.pluck(_.at(nodeArray, selectedArray), 'id')
        Message.postMessage
          request: 'removeBookmark'
          idArray: idArray

        # Remove the bookmark from screen using animation
        timeOutFunc = =>
          leftNodeIndexArray =
            _.difference([0...nodeArray.length], selectedArray)
          leftNodeArray = _.at(nodeArray, leftNodeIndexArray)

          # Push node index back by the number of selected nodes before it
          currentNodeFullIndex = @getCurrentNodeFullIndex()
          nodeBeforeCurrent = _.filter selectedArray, (nodeIndex) ->
            nodeIndex < currentNodeFullIndex

          futureIndex = currentNodeFullIndex - nodeBeforeCurrent.length
          futureIndex = 0 if futureIndex < 0

          futureNodeIndex = futureIndex % MAX
          futurePageIndex = Math.floor(futureIndex / MAX)

          @setState
            nodeArray: leftNodeArray
            selectedArray: []

            nodeAnimation: {}

            currentNodeIndex: futureNodeIndex
            currentPageIndex: futurePageIndex

          # Return to query mode if there is no search results 
          @setState({ mode: 'query' }) if _.isEmpty(@state.nodeArray)

        setTimeout(timeOutFunc, 350)

  # ------------------------------------------------------------
  # Open last opened windows
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
  # Cache
  # ------------------------------------------------------------

  storeCache: (cache) ->
    if cache
      @setState { cache }
    else
      @setDeepState
        cache:
          input: @state.input
          nodeArray: _.cloneDeep(@state.nodeArray)
          selectedArray: @state.selectedArray

  clearCache: ->
    @setState
      cache:
        input: ''
        nodeArray: []
        selectedArray: []

  recoverFromCache: (cache) ->
    if cache
      @setState
        input: cache.input
        nodeArray: cache.nodeArray
        selectedArray: cache.selectedArray
    else
      @setState
        input: @state.cache.input
        nodeArray: @state.cache.nodeArray
        selectedArray: @state.cache.selectedArray

  # Recover from the current cache, but store current state in cache
  # before recovering
  storeAndRecoverFromCache: ->
    currentCache = _.cloneDeep(@state.cache)
    @callAction('n_storeCache')
    @callAction('n_recoverFromCache', [currentCache])

  # ------------------------------------------------------------
  # Caret movement and word processing
  # ------------------------------------------------------------

  setCaretToStart: ->
    if @state.mode is 'query'
      Util.setCaretRange(0, 0)
    else
      if @state.specialMode isnt 'no'
        Util.setCaretRange(0, 0)
      else
        Util.setCaretRange(1, 1)
    
  setCaretToEnd: ->
    Util.setCaretRange(@state.input.length, @state.input.length)

  setCaretToPrevWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()
    
    beforeCaret = input[0...start]
    afterCaret = input[start...]

    beforeCaretArray = beforeCaret.split(' ')

    spaceTokenNum = (_.last beforeCaretArray, (s) ->
      s is ""
    ).length

    leftTokenSize = Math.max(0, beforeCaretArray.length - spaceTokenNum - 1)
    position = beforeCaretArray[0...leftTokenSize].join(' ').length

    Util.setCaretRange(position, position)
    
  setCaretToNextWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()

    beforeCaret = input[0...start]
    afterCaret = input[start...]

    afterCaretArray = afterCaret.split(' ')

    spaceTokenNum = (_.first afterCaretArray, (s) ->
      s is ""
    ).length

    position = beforeCaret.length +
      afterCaretArray[0...spaceTokenNum + 1].join(' ').length

    Util.setCaretRange(position, position)

  deletePrevWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()
    
    beforeCaret = input[0...start]
    afterCaret = input[start...]

    beforeCaretArray = beforeCaret.split(' ')

    spaceTokenNum = (_.last beforeCaretArray, (s) ->
      s is ""
    ).length

    leftTokenSize = Math.max(0, beforeCaretArray.length - spaceTokenNum - 1)
    input = beforeCaretArray[0...leftTokenSize].join(' ') + afterCaret
    position = beforeCaretArray[0...leftTokenSize].join(' ').length

    @setState { input }
    Util.setCaretRange(position, position)

  deleteNextWord: ->
    input = @state.input
    [start, end] = Util.getCaretPosition()

    beforeCaret = input[0...start]
    afterCaret = input[start...]

    afterCaretArray = afterCaret.split(' ')

    spaceTokenNum = (_.first afterCaretArray, (s) ->
      s is ""
    ).length

    console.log afterCaretArray
    console.log spaceTokenNum
    input = beforeCaret + afterCaretArray[spaceTokenNum + 1...].join(' ')

    @setState { input }
    Util.setCaretRange(start, start)

  # ------------------------------------------------------------
  # Session
  # ------------------------------------------------------------

  openSession: (command, modifierString) ->
    sessionRecord = @state.sessionMap[command]

    if sessionRecord.type is 'window'
      nodeArray = sessionRecord.session
      
      openArgs = switch modifierString
        when ''       then [{ active:    yes }, no , yes, nodeArray]
        when 's-'     then [{ active:    no  }, no , no , nodeArray]
        when 'c-'     then [{ incognito: no  }, yes, yes, nodeArray]
        when 'c-s-'   then [{ incognito: yes }, yes, yes, nodeArray]

      @callAction('n_openHelper', openArgs)
    else
      _.forEach sessionRecord.session, (nodeArray) =>
        openArgs = switch modifierString
          when ''       then [{ incognito: no  }, yes, yes, nodeArray]
          when 's-'     then [{ incognito: yes }, yes, yes, nodeArray]

        @callAction('n_openHelper', openArgs)

