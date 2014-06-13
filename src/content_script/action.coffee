Action =
  # match actionName to real action function
  matchAction: (actionName) ->
    switch actionName[0..1]
      when 'q_' then QueryAction[actionName[2..]]
      when 'f_' then FastAction[actionName[2..]]
      when 'c_' then CommandAction[actionName[2..]]
      else CommonAction[actionName]

CommonAction =
  noop: _.noop

  print: ->
    console.log @state
  
  toggle: ->
    if @state.visible
      CommonAction.reset.call(@)
      @setState
        visible: false
    else
      @setState
        visible: true
      $('.lynn_console').focus()

  hide: ->
    CommonAction.reset.call(@)
    @setState { visible: false }

  open: ->
    Message.postMessage
      request: 'openBookmark'
      action: yes
      node: @getCurrentNode()
      option:
        active: no

  up: ->
    currentNodeIndex = \
      (@state.currentNodeIndex + @state.MAX_SUGGESTION_NUM - 1) %
        @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  down: ->
    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  pageUp: ->
    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    currentPageLastNodeIndex =
      (@state.currentPageIndex + 1) * @state.MAX_SUGGESTION_NUM
    if currentPageLastNodeIndex < @state.nodeArray.length
      @setState
        currentPageIndex: @state.currentPageIndex + 1
        currentNodeIndex: 0
      
  reset: ->
    @setState
      input: ''
      mode: 'query'

      nodeArray: []
      selectedArray: []

      currentNodeIndex: 0
      currentPageIndex: 0

  nextMode: ->
    if @state.mode is 'query'
      mode = 'fast'
    else if @state.mode is 'fast'
      mode = 'command'
    else
      mode = 'query'

    @setState { mode }
    
  prevMode: ->
    if @state.mode is 'fast'
      mode = 'query'
    else if @state.mode is 'command'
      mode = 'fast'
    else
      mode = 'command'

    @setState { mode }

QueryAction =

FastAction =
  open: ->
    nodeArray = _.filter @state.nodeArray, (node, index) =>
      _.contains(@state.selectedArray, index)
    Message.postMessage { request: 'openNodeArray', nodeArray }

  select: ->
    selectedNodeIndex = @state.currentNodeIndex +
      @state.currentPageIndex * @state.MAX_SUGGESTION_NUM
    unless _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = _.union(@state.selectedArray, [selectedNodeIndex])
      @setState { selectedArray }

  unselect: ->
    selectedNodeIndex = @state.currentNodeIndex +
      (@state.currentPageIndex) * @state.MAX_SUGGESTION_NUM
    if _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = _.without(@state.selectedArray, selectedNodeIndex)
      @setState { selectedArray }

CommandAction =
  execute: ->
    tokenArray = @state.input.split(' ')
    # example or custom shortcuts
    if tokenArray[0] is ':g'
      Message.postMessage
        request: 'open'
        node:
          url: 'http://www.google.com'
          isBookmark: true

    if tokenArray[0] is ':tag'
      Message.postMessage
        request: @state.input.slice(1)
        node: @getCurrentNode()

    if tokenArray[0] is ':sync'
      Message.postMessage
        request: 'sync'

