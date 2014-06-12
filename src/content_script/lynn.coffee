MAX_SUGGESTION_NUM = 8

{ div, span } = React.DOM

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
    { input } = React.DOM
    if @props.mode is 'command'
      inputPlaceHolder = 'Your command...'
    else
      inputPlaceHolder = 'Search for...'

    div className: 'lynn_top',
      input
        className: 'lynn_console'
        type: 'text'
        size: '80'
        placeholder: inputPlaceHolder

        value: @props.input
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
    start = @props.currentPageIndex * @props.MAX_SUGGESTION_NUM
    end = Math.min(@props.nodeArray.length, start + @props.MAX_SUGGESTION_NUM)
    className = 'lynn_mid'

    if @props.mode is 'query'
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          Suggestion
            key: node.id

            node: node
            isCurrent: index is @props.currentNodeIndex
            isSelected: false
    else
      div {className},
        _.map @props.nodeArray[start...end], (node, index) =>
          Suggestion
            key: node.id

            node: node
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
        'Page ' + numToString[@props.currentPageIndex + 1]

# lynn
Lynn = React.createClass
  # @state
  #   - getInitialState
  #   - option loaded in componentWillMount

  # React methods
  getInitialState: ->
    visible: no
    input: ''
    mode: 'query' # query | select | command

    nodeArray: []
    selectedArray: []

    currentNodeIndex: 0
    currentPageIndex: 0

  componentWillMount: ->
    # listen to search callback
    Message.addListener (message) =>
      if message.response && message.response is 'search'
        @setState nodeArray: message.result

    # keydown events
    $(document).keydown (event) =>
      # Global invoke
      if KeyMatch.ctrlB(event)
        CommonAction.toggle.call(@)

      else
        # Shortcut when lynn is shown
        if @state.visible
          actionName = KeyMatch.match(event, @state.mode)
          Action.matchAction(actionName).call(@, event)

    # ~ 
    # load options
    @setState { MAX_SUGGESTION_NUM }

  render: ->
    className = 'lynn animated fadeInDown'
    className += ' hidden' unless @state.visible

    div {className},
      Top
        input: @state.input
        mode: @state.mode

        onConsoleChange: @onConsoleChange

      Mid
        MAX_SUGGESTION_NUM: @state.MAX_SUGGESTION_NUM

        mode: @state.mode

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        currentNodeIndex: @state.currentNodeIndex
        currentPageIndex: @state.currentPageIndex

      Bot
        mode: @state.mode

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        currentPageIndex: @state.currentPageIndex


  onConsoleChange: (event) ->
    input = event.target.value
    if @state.mode is 'query'
      @setState
        input: input
        mode: if input[0] is ':' then 'command' else 'query'
        currentNodeIndex: 0
        currentPageIndex: 0

      if input[0] isnt ':'
        Message.postMessage
          request: 'search'
          command: input
    else
      @setState { input }
