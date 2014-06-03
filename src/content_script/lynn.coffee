MAX_SUGGESTION_NUM = 8

{ div, span, input } = React.DOM

###
Structure

div.lynn
  div.lynn_top
    input.lynn_console
    span.lynn_console_status
  div.lynn_mid
    [div.lynn_suggestion]
      div.lynn_mainline
        span.lynn_title
      div.lynn_tagline
        [span.lynn_tag]
  div.lynn_bot
    span.lynn_info
    span.lynn_pageView

###

# lynn_top

Top = React.createClass
  render: ->
    div className: 'lynn_top',
      input
        className: 'lynn_console'
        type: 'text'
        size: '80'
        value: @props.command
        placeholder: 'Search for...'
        onChange: @props.onConsoleChange

      span className: 'lynn_console_status',
        if @props.command_mode is 'query'
          span className: 'lynn_console_status_icon fa fa-search fa-2x'
        else if @props.command_mode is 'select'
          span className: 'lynn_console_status_icon fa fa-files-o fa-2x'
        else
          span className: 'lynn_console_status_icon fa fa-terminal fa-2x'

# lynn_mid

Mid = React.createClass
  render: ->
    start = (@props.currentPage - 1) * @props.maxSuggestionNum
    end = Math.min(@props.nodeArray.length, start + @props.maxSuggestionNum)
    className = 'lynn_mid'
    className += ' hidden' if not @props.visible

    if @props.command_mode is 'query'
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          Suggestion
            title: node.title
            tagArray: node.tagArray
            key: node.id
            isCurrent: index is @props.currentNodeIndex
    else
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          Suggestion
            title: node.title
            tagArray: node.tagArray
            key: node.id
            isCurrent: index is @props.currentNodeIndex
            isSelected: _.contains(@props.selectedArray, index)


Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion animated fadeInDown'
    className += ' lynn_suggestion_current' if @props.isCurrent
    className += ' lynn_suggestion_selected' if @props.isSelected

    div {className},
      div className: 'lynn_mainline',
        span className: 'lynn_title',
          @props.title
      div className: 'lynn_tagline',
        _.map @props.tagArray, (tag) ->
          if tag[0] is '@'
            span {className: 'lynn_tag'}, tag
          else
            span {className: 'lynn_tag'}, '#', tag

# lynn_bot

Bot = React.createClass
  render: ->
    numToString = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten']

    className = 'lynn_bot'
    className += ' hidden' if not @props.visible

    infoString = @props.nodeArray.length + ' result'
    infoString += 's' if @props.nodeArray.length > 1
    selectString = ''
    if @props.command_mode is 'select'
      selectString += @props.selectedArray.length + ' selected'
      
    div {className},
      span className: 'lynn_info',
        infoString
      span className: 'lynn_select_info',
        selectString
      span className: 'lynn_pageView',
        'Page ' + numToString[@props.page]

# lynn

Lynn = React.createClass
  getInitialState: ->
    # Global
    visible: no

    # Top
    command: ''
    command_mode: 'query' # query | select | command

    # Mid
    nodeArray: []
    selectedArray: []
    maxSuggestionNum: MAX_SUGGESTION_NUM
    currentNodeIndex: 0
    currentPage: 1

    # Bot

  componentWillMount: ->
    Message.addListener (message) =>
      if message.response is 'search'
        @setState nodeArray: message.result
    
    $(document).keydown (event) =>
      # Global invoke
      if KeyMatch.c_b(event)
        @toggle()

      else
        # Shortcut when lynn is shown
        if @state.visible
          if @state.command_mode is 'query'
            @[KeyMatch.switchInQueryMode event] event
          else if @state.command_mode is 'select'
            @[KeyMatch.switchInSelectMode event] event
          else
            @[KeyMatch.switchInCommandMode event] event

  render: ->
    className = 'lynn animated fadeInDown'
    className += ' hidden' unless @state.visible

    div {className},
      Top
        onConsoleChange: @onConsoleChange
        command: @state.command
        command_mode: @state.command_mode
      Mid
        visible: not _.isEmpty @state.command
        nodeArray: @state.nodeArray
        maxSuggestionNum: @state.maxSuggestionNum
        currentNodeIndex: @state.currentNodeIndex
        currentPage: @state.currentPage
        command_mode: @state.command_mode
        selectedArray: @state.selectedArray
      Bot
        visible: not _.isEmpty @state.command
        nodeArray: @state.nodeArray
        page: @state.currentPage

        command_mode: @state.command_mode
        selectedArray: @state.selectedArray

  # Event Handlers
  onConsoleChange: (event) ->
    command = event.target.value
    if command[0] is ':'
      @setState
        command: command
        command_mode: 'command'
        currentNodeIndex: 0
        currentPage: 1
    else
      @setState
        command: command
        command_mode: 'query'
        currentNodeIndex: 0
        currentPage: 1

      Message.postMessage {request: 'search', command}


  # Helpers used in shortcuts
  noop: _.noop # for unmatched shortcuts
  
  toggle: ->
    if @state.visible
      @reset()
      @setState
        visible: false
    else
      @setState
        visible: true
      $('.lynn_console').focus()

  # -- query mode helpers
  open: ->
    node = @state.nodearray[@state.currentnodeindex]
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

  # -- select mode helpers
  s_select: (event) ->
    event.preventDefault()
    selectedNodeIndex = @state.currentNodeIndex +
      (@state.currentPage - 1) * @state.maxSuggestionNum
    unless _.contains(@state.selectedArray, selectedNodeIndex)
      selectedArray = @state.selectedArray.concat([selectedNodeIndex])
      @setState {selectedArray}

  s_open: (event) ->
    nodeArray = _.filter @state.nodeArray, (node, index) =>
      _.contains(@state.selectedArray, index)
    Message.postMessage {request: 'openNodeArray', nodeArray}

