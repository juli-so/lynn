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
    ?
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

    div {className},
      _.map @props.nodeArray[start...end], (node, index) =>
        if index is @props.currentNodeIndex
          Suggestion
            title: node.title
            tagArray: node.tagArray
            key: node.id
            isCurrent: yes
        else
          Suggestion
            title: node.title
            tagArray: node.tagArray
            key: node.id
            isCurrent: false

Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion animated fadeInLeft'
    className += ' lynn_suggestion_current' if @props.isCurrent
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

    div {className},
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
          @[KeyMatch.switch(event)]()

  render: ->
    div className: 'lynn',
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
      Bot
        visible: not _.isEmpty @state.command
        page: @state.currentPage

  # Event Handlers
  onConsoleChange: (event) ->
    command = event.target.value
    command_mode = if command[0] is ':' then 'command' else 'query'
    @setState {command, command_mode, currentNodeIndex: 0, currentPage: 1}

    Message.postMessage {request: 'search', command}


  # Helpers used in shortcuts
  noop: _.noop # for unmatched shortcuts
  
  toggle: ->
    @setState visible: not @state.visible
    $('.lynn').toggle()
    if @state.visible
      $('.lynn_console').focus()

  open: ->
    node = @state.nodeArray[@state.currentNodeIndex]
    Message.postMessage {request: 'open', node}

  up: ->
    currentNodeIndex = (@state.currentNodeIndex + @state.maxSuggestionNum - 1) \
      % @state.maxSuggestionNum
    @setState {currentNodeIndex}

  down: ->
    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.maxSuggestionNum
    @setState {currentNodeIndex}


  pageUp: ->
    if @state.currentPage > 1
      @setState
        currentPage: @state.currentPage - 1
        currentNodeIndex: 0

  pageDown: ->
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

