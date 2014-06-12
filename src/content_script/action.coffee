Action =
  # match actionName to real action function
  matchAction: (actionName) ->
    switch actionName[0..1]
      when 'q_' then QueryAction[actionName[2..]]
      when 's_' then SelectAction[actionName[2..]]
      when 'c_' then CommandAction[actionName[2..]]
      else SharedAction[actionName]

SharedAction =
  noop: _.noop

  print: (event) ->
    event.preventDefault()
    console.log @state
  
  toggle: ->
    if @state.visible
      SharedAction.reset.call(@)
      @setState
        visible: false
    else
      @setState
        visible: true
      $('.lynn_console').focus()

  hide: (event) ->
    event.preventDefault()
    SharedAction.reset.call(@)
    @setState { visible: false }

  open: ->
    node = @state.nodeArray[@state.currentNodeIndex]
    Message.postMessage { request: 'open', node }

  up: (event) ->
    event.preventDefault()

    currentNodeIndex = \
      (@state.currentNodeIndex + @state.MAX_SUGGESTION_NUM - 1) %
        @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  down: (event) ->
    event.preventDefault()

    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  pageUp: ->
    event.preventDefault()

    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    event.preventDefault()

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

  nextMode: (event) ->
    event.preventDefault()

    if @state.mode is 'query'
      mode = 'select'
    else if @state.mode is 'select'
      mode = 'command'
    else
      mode = 'query'

    @setState { mode }
    @setState { input: '' } if mode is 'command'
    
  prevMode: (event) ->
    event.preventDefault()

    if @state.mode is 'select'
      mode = 'query'
    else if @state.mode is 'command'
      mode = 'select'
    else
      mode = 'command'

    @setState { mode }
    @setState { input: '' } if mode is 'command'

QueryAction =

SelectAction =
  select: (event) ->
    event.preventDefault()

    selectedNodeIndex = @state.currentNodeIndex +
      @state.currentPageIndex * @state.MAX_SUGGESTION_NUM
    unless _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = _.union(@state.selectedArray, [selectedNodeIndex])
      @setState { selectedArray }

  unselect: (event) ->
    event.preventDefault()

    selectedNodeIndex = @state.currentNodeIndex +
      (@state.currentPageIndex) * @state.MAX_SUGGESTION_NUM
    if _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = _.without(@state.selectedArray, selectedNodeIndex)
      @setState { selectedArray }

  open: (event) ->
    event.preventDefault()

    nodeArray = _.filter @state.nodeArray, (node, index) =>
      _.contains(@state.selectedArray, index)
    Message.postMessage { request: 'openNodeArray', nodeArray }

CommandAction =
  execute: (event) ->
    tokenArray = @state.input.split(' ')
    # example or custom shortcuts
    if tokenArray[0] is ':1'
      Message.postMessage
        request: 'open'
        node:
          url: 'http://www.google.com'
          isBookmark: true

    if tokenArray[0] is ':tag'
      currenNode = @state.nodeArray[@state.currentNodeIndex +
        @state.currentPageIndex * @state.MAX_SUGGESTION_NUM]
      Message.postMessage
        request: @state.input.slice(1)
        node: currenNode

    if tokenArray[0] is ':sync'
      Message.postMessage
        request: 'sync'
