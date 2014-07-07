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
    else if @props.mode is 'fast'
      inputPlaceHolder = 'Invoke fast command!'
    else
      inputPlaceHolder = 'Search for...'

    div { id: 'lynn_top' },
      input
        ref: 'lynn_console'
      
        className: 'lynn_console'
        type: 'text'
        size: '80'
        placeholder: inputPlaceHolder

        value: @props.input
        onChange: @props.onConsoleChange

      span className: 'lynn_console_status',
        span
          className: 'lynn_console_status_icon fa fa-2x ' + switch @props.mode
            when 'query'   then 'fa-search'
            when 'fast'    then 'fa-bolt'
            when 'command' then 'fa-terminal'

  componentDidUpdate: (prevProps, prevState) ->
    # focus input when toggled from invisible to visible
    if not prevProps.visible and @props.visible
      @refs.lynn_console.getDOMNode().focus()

# lynn_mid

Mid = React.createClass
  render: ->
    start = @props.currentPageIndex * @props.MAX_SUGGESTION_NUM
    end = Math.min(@props.nodeArray.length, start + @props.MAX_SUGGESTION_NUM)

    div { id: 'lynn_mid' },
      _.map @props.nodeArray[start...end], (node, index) =>
        # live tagging when adding tags
        pendingTagArray = []
        if @props.specialMode is 'tag'
          if _.isEmpty(@props.selectedArray)
            if index is @props.currentNodeIndex
              pendingTagArray = @props.pendingTagArray
          else
            if _.contains(@props.selectedArray, start + index)
              pendingTagArray = @props.pendingTagArray

        Suggestion
          key: node.id

          node: node
          isCurrent: index is @props.currentNodeIndex
          isSelected: _.contains(@props.selectedArray, start + index)

          pendingTagArray: pendingTagArray


Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion animated fadeInDown'
    className += ' lynn_suggestion_current' if @props.isCurrent
    className += ' lynn_suggestion_selected' if @props.isSelected

    div { className },
      div className: 'lynn_mainline',
        span className: 'lynn_title',
          @props.node.title
      div className: 'lynn_tagline',
        _.map @props.node.tagArray, (tag) ->
          span { className: 'lynn_tag' }, tag
        _.map @props.pendingTagArray, (tag) ->
          span { className: 'lynn_pending_tag' }, tag

# lynn_bot

Bot = React.createClass
  render: ->
    numToString = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten']

    specialModeStringMap =
      'tag': 'Tag'
      'addBookmark': 'Add Bookmark'
      'addMultipleBookmark': 'Add multiple Bookmark'
      'addAllBookmark': 'Add all bookmark'

    infoString = @props.nodeArray.length + ' result'
    infoString += 's' if @props.nodeArray.length > 1
      
    div { id: 'lynn_bot' },
      span className: 'lynn_bot_left',
        infoString
      span className: 'lynn_bot_mid',
        if @props.specialMode is 'no'
          ''
        else
          'Speical Mode: ' + specialModeStringMap[@props.specialMode]
      span className: 'lynn_bot_right',
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

    mode: 'query' # query | fast | command
    # in special mode, mode and nodeArray change won't be triggered
    # when 'no' it is disabled
    specialMode: 'no'

    # when 'no' animation is disabled
    animation: 'fadeInDown'

    nodeArray: []
    selectedArray: []

    currentNodeIndex: 0
    currentPageIndex: 0

    pendingTagArray: []

    cache:
      input: ''
      selectedArray: []

  componentWillMount: ->
    Listener.setListener 'search', (message) =>
      if message.response is 'search'
        @setState nodeArray: message.result

    # keydown events
    $(document).keydown (event) =>
      # Global invoke
      if KeyMatch.isInvoked(event)
        CommonAction.toggle.call(@)

      else
        # Shortcut when lynn is shown
        if @state.visible
          actionName = KeyMatch.match(event, @state.mode, @state.specialMode)
          event.preventDefault() if actionName isnt 'noop'

          @callAction(actionName)

    # ~ 
    # load options
    @setState { MAX_SUGGESTION_NUM }

  # ------------------------------------------------------------

  render: ->
    id = 'lynn'
    className = ''
    if @state.animation isnt 'no'
      className += 'animated ' + @state.animation
    className += ' hidden' unless @state.visible

    div { id, className },
      Top
        visible: @state.visible

        input: @state.input
        mode: @state.mode

        onConsoleChange: @onConsoleChange

      Mid
        MAX_SUGGESTION_NUM: @state.MAX_SUGGESTION_NUM

        mode: @state.mode
        specialMode: @state.specialMode

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        currentNodeIndex: @state.currentNodeIndex
        currentPageIndex: @state.currentPageIndex

        pendingTagArray: @state.pendingTagArray

      Bot
        mode: @state.mode
        specialMode: @state.specialMode

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        currentPageIndex: @state.currentPageIndex

  # ------------------------------------------------------------

  onConsoleChange: (event) ->
    input = event.target.value

    handler = Handler.matchHandler(@state.mode, @state.specialMode)
    if handler
      handler.call(@, event)

  # ------------------------------------------------------------
  # helper functions for getting data

  getCurrentNodeIndex: ->
    @state.currentPageIndex * @state.MAX_SUGGESTION_NUM +
      @state.currentNodeIndex

  getCurrentNode: ->
    @state.nodeArray[@getCurrentNodeIndex()]

  getNodeIndexStart: ->
    @state.currentPageIndex * @state.MAX_SUGGESTION_NUM

  getNodeIndexEnd: ->
    start = @getNodeIndexStart()
    Math.min(@state.nodeArray.length, start + @state.MAX_SUGGESTION_NUM)

  # ------------------------------------------------------------
  # helping functions for setting states

  callAction: (actionName, params) ->
    Action.matchAction(actionName).apply(@, params)

  setDeepState: (state) ->
    _.forEach state, (val, key) =>
      if _.isPlainObject(val)
        state[key] = _.assign(@state[key], val)

    @setState(state)
