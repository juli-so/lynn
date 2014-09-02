CommonAction =
  noop: _.noop

  print: ->
    console.log @state
  
  # ------------------------------------------------------------

  hide: ->
    @setState { animation: 'fadeOutUp' }

    timeOutFunc = =>
      @setState { visible: no }
      @callAction('reset')

    setTimeout(timeOutFunc, 200)

  show: ->
    @setState
      visible: yes
      animation: 'fadeInDown'

  toggle: ->
    if @state.visible
      @callAction('hide')
    else
      @callAction('show')

  reset: ->
    @setDeepState
      input: ''

      mode: 'query'
      specialMode: 'no'

      nodeArray: []
      selectedArray: []

      useSuggestedTag: yes

      currentNodeIndex: 0
      currentPageIndex: 0

      cache:
        input: ''
        selectedArray: []

  resetSearchResult: ->
    @setState
      nodeArray: []
      selectedArray: []

      currentNodeIndex: 0
      currentPageIndex: 0

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
        @callAction('pageUp')
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
  
  openHelper: (option, newWindow, needHide) ->
    message =
      request: if newWindow then 'openInNewWindow' else 'open'
      option: option

    if _.isEmpty(@state.selectedArray)
      message['node'] = @getCurrentNode()
    else
      message['nodeArray'] = @getSelectedNodeArray()

    Message.postMessage(message)
    if needHide then @callAction('hide')

  open: ->
    @callAction('openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('openHelper', [{ active:    no  }, no , no ])

  openInNewWindow: ->
    @callAction('openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWindow: ->
    @callAction('openHelper', [{ incognito: yes }, yes, yes])

  # ------------------------------------------------------------

  test: ->
    console.log @getCurrentNodeFullIndex()
