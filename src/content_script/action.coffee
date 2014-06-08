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
  
  toggle: ->
    if @state.visible
      SharedAction.reset.call(@)
      @setState
        visible: false
    else
      @setState
        visible: true
      $('.lynn_console').focus()

  open: ->
    node = @state.nodeArray[@state.currentNodeIndex]
    Message.postMessage {request: 'open', node}

  up: (event) ->
    event.preventDefault()
    currentNodeIndex = (@state.currentNodeIndex + @state.maxSuggestionNum - 1) \
      % @state.maxSuggestionNum
    @setState {currentNodeIndex}

  down: (event) ->
    event.preventDefault()
    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.maxSuggestionNum
    @setState {currentNodeIndex}

  pageUp: ->
    event.preventDefault()
    if @state.currentPage > 1
      @setState
        currentPage: @state.currentPage - 1
        currentNodeIndex: 0

  pageDown: ->
    event.preventDefault()
    if @state.currentPage * @state.maxSuggestionNum < @state.nodeArray.length
      @setState
        currentPage: @state.currentPage + 1
        currentNodeIndex: 0
      
  reset: ->
    @setState
      command: ''
      command_mode: 'query'

      nodeArray: []
      selectedArray: []
      currentNodeIndex: 0
      currentPage: 1

  nextCommandMode: (event) ->
    event.preventDefault()
    if @state.command_mode is 'query'
      command_mode = 'select'
    else if @state.command_mode is 'select'
      command_mode = 'command'
    else
      command_mode = 'query'

    @setState {command_mode}
    
  prevCommandMode: (event) ->
    event.preventDefault()
    if @state.command_mode is 'select'
      command_mode = 'query'
    else if @state.command_mode is 'command'
      command_mode = 'select'
    else
      command_mode = 'command'

    @setState {command_mode}

QueryAction =

SelectAction =
  select: (event) ->
    event.preventDefault()
    selectedNodeIndex = @state.currentNodeIndex +
      (@state.currentPage - 1) * @state.maxSuggestionNum
    unless _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = @state.selectedArray.concat([selectedNodeIndex])
      @setState {selectedArray}

  open: (event) ->
    nodeArray = _.filter @state.nodeArray, (node, index) =>
      _.contains(@state.selectedArray, index)
    Message.postMessage {request: 'openNodeArray', nodeArray}

CommandAction =
  open: (event) ->
    console.log @s
    if @state.command is ':g'
      Message.postMessage
        request: 'open'
        node:
          url: 'http://www.google.com'
          isBookmark: true

