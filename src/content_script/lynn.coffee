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
        if @props.mode is 'query'
          span className: 'lynn_console_status_icon fa fa-search fa-2x'
        else if @props.mode is 'select'
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

    if @props.mode is 'query'
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          Suggestion
            node: node
            key: node.id
            isCurrent: index is @props.currentNodeIndex
    else
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          console.log node
          Suggestion
            node: node
            key: node.id
            isCurrent: index is @props.currentNodeIndex
            isSelected: _.contains(@props.selectedArray, start + index)


Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion animated fadeInDown'
    className += ' lynn_suggestion_current' if @props.isCurrent
    className += ' lynn_suggestion_selected' if @props.isSelected

    div {className},
      div className: 'lynn_mainline',
        span className: 'lynn_title',
          @props.node.title
      div className: 'lynn_tagline',
        _.map @props.node.tagArray, (tag) ->
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
    if @props.mode is 'select'
      selectString += @props.selectedArray.length + ' selected'
      
    div {className},
      span className: 'lynn_info',
        infoString
      span className: 'lynn_select_info',
        selectString
      span className: 'lynn_pageView',
        'Page ' + numToString[@props.currentPage]

# lynn

Lynn = React.createClass
  getInitialState: ->
    # Global
    visible: no

    # Top
    command: ''
    mode: 'query' # query | select | command

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
      if KeyMatch.ctrlB(event)
        SharedAction.toggle.call(@)

      else
        # Shortcut when lynn is shown
        if @state.visible
          actionName = KeyMatch.match(event, @state.mode)
          Action.matchAction(actionName).call(@, event)

  render: ->
    className = 'lynn animated fadeInDown'
    className += ' hidden' unless @state.visible

    div {className},
      Top
        onConsoleChange: @onConsoleChange
        command: @state.command
        mode: @state.mode
      Mid
        visible: not _.isEmpty @state.command
        nodeArray: @state.nodeArray
        maxSuggestionNum: @state.maxSuggestionNum
        currentNodeIndex: @state.currentNodeIndex
        currentPage: @state.currentPage
        mode: @state.mode
        selectedArray: @state.selectedArray
      Bot
        visible: not _.isEmpty @state.command
        nodeArray: @state.nodeArray
        currentPage: @state.currentPage

        mode: @state.mode
        selectedArray: @state.selectedArray

  onConsoleChange: (event) ->
    command = event.target.value
    if command[0] is ':'
      @setState
        command: command
        mode: 'command'
        currentNodeIndex: 0
        currentPage: 1
    else
      @setState
        command: command
        mode: 'query'
        currentNodeIndex: 0
        currentPage: 1

      Message.postMessage {request: 'search', command}


