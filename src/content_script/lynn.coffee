{ div, span } = React.DOM

Top = React.createClass
  render: ->
    { input } = React.DOM

    if @props.specialMode isnt 'no'
      inputPlaceHolder =
        Hint.inputPlaceHolderSpecialModeMap[@props.specialMode]
    else
      inputPlaceHolder = switch @props.mode
        when 'query' then 'Search for...'
        when 'fast' then 'Invoke fast command!'
        when 'command' then 'Your command...'

    div { id: 'lynn_top' },
      input
        ref: 'lynn_console'
      
        id: 'lynn_console'
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

Mid = React.createClass
  render: ->
    div { id: 'lynn_mid' },
      _.map @props.nodeArray[@props.start...@props.end], (node, index) =>
        animation = @props.nodeAnimation[index] || 'fadeInLeft'

        Suggestion
          key: node.id

          node: node
          isCurrent: index is @props.currentNodeIndex
          isSelected: _.contains(@props.selectedArray, @props.start + index)

          animation: animation

          useSuggestedTag: @props.useSuggestedTag

Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion animated '
    className += @props.animation
    className += ' lynn_suggestion_current' if @props.isCurrent
    className += ' lynn_suggestion_selected' if @props.isSelected

    div { className },
      div className: 'lynn_mainline',
        span className: 'lynn_title',
          @props.node.title
      div className: 'lynn_tagline',
        if @props.useSuggestedTag
          _.map @props.node.suggestedTagArray, (tag) ->
            span { className: 'lynn_suggested_tag' }, tag

        _.map @props.node.tagArray, (tag) ->
          span { className: 'lynn_tag' }, tag
        _.map @props.node.pendingTagArray, (tag) ->
          span { className: 'lynn_pending_tag' }, tag

Bot = React.createClass
  render: ->
    numToString = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten']

    infoString = @props.nodeArray.length + ' result'
    infoString += 's' if @props.nodeArray.length > 1

      
    div { id: 'lynn_bot' },
      span className: 'lynn_bot_left',
        infoString
      span className: 'lynn_bot_mid',
        if @props.specialMode is 'no'
          ''
        else
          botString = Hint.botStringSpecialModeMap[@props.specialMode]
          if @props.specialMode is 'storeWindowSession' or
            @props.specialMode is 'storeChromeSession' or
            @props.specialMode is 'removeSession'
              sessionName = @props.input.split(' ')[0]
              botString += sessionName

          'Speical Mode: ' + botString
      span className: 'lynn_bot_right',
        'Page ' + numToString[@props.currentPageIndex + 1]

Lynn = React.createClass
  getInitialState: ->
    visible: no
    input: ''

    mode: 'query' # query | fast | command
    # in special mode, mode and nodeArray change won't be triggered
    # when 'no' it is disabled
    specialMode: 'no'

    # when 'no' animation is disabled
    animation: 'fadeInDown'
    # nodeIndex -> animation string
    nodeAnimation: {}

    nodeArray: []
    selectedArray: []

    useSuggestedTag: yes

    currentNodeIndex: 0
    currentPageIndex: 0

    cache:
      input: ''
      nodeArray: []
      selectedArray: []

    # loaded from storage
    option:
      MAX_SUGGESTION_NUM: 8

    sessionMap: {}

  componentWillMount: ->
    Listener.listen 'search', (message) =>
      @setState nodeArray: message.result

    Listener.listen 'getSyncStorage', (message) =>
      @setState
        option: message.storageObject.option || @state.option
        sessionMap: message.storageObject.sessionMap || @state.sessionMap

    Message.postMessage { request: 'getSyncStorage' }

    # keydown events
    $(window).keydown (event) =>
      # Global invoke
      if ActionMatch.isInvoked(event)
        @callAction('n_toggle')

      else
        # Shortcut when lynn is shown
        if @state.visible
          actionName = ActionMatch.findActionName(event, @state.mode, @state.specialMode)
          event.preventDefault() if actionName isnt 'noop'

          @callAction(actionName)

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
        specialMode: @state.specialMode

        onConsoleChange: @onConsoleChange

      Mid
        start: @getNodeIndexStart()
        end: @getNodeIndexEnd()

        mode: @state.mode
        specialMode: @state.specialMode

        nodeAnimation: @state.nodeAnimation

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        useSuggestedTag: @state.useSuggestedTag

        currentNodeIndex: @state.currentNodeIndex
        currentPageIndex: @state.currentPageIndex

      Bot
        input: @state.input

        mode: @state.mode
        specialMode: @state.specialMode

        nodeArray: @state.nodeArray
        selectedArray: @state.selectedArray

        currentPageIndex: @state.currentPageIndex

  # ------------------------------------------------------------

  onConsoleChange: (event) ->
    input = event.target.value

    handler = InputHandler.matchHandler(@state.mode, @state.specialMode)
    handler.call(@, input) if handler

  # ------------------------------------------------------------
  # Helper functions for getting data

  getCurrentNodeFullIndex: ->
    @state.currentPageIndex * @state.option.MAX_SUGGESTION_NUM +
      @state.currentNodeIndex

  getCurrentNode: ->
    @state.nodeArray[@getCurrentNodeFullIndex()]

  getSelectedNodeArray: ->
    _.at(@state.nodeArray, @state.selectedArray)

  getNodeIndexStart: ->
    @state.currentPageIndex * @state.option.MAX_SUGGESTION_NUM

  getNodeIndexEnd: ->
    start = @getNodeIndexStart()
    Math.min(@state.nodeArray.length, start + @state.option.MAX_SUGGESTION_NUM)

  getCurrentPageNodeArray: ->
    @state.nodeArray[@getNodeIndexStart()...@getNodeIndexEnd()]

  hasNoSelection: ->
    _.isEmpty(@state.selectedArray)

  hasSelection: ->
    not @hasNoSelection()

  isResetted: ->
    return yes and
      @state.input is '' and

      @state.mode is 'query' and
      @state.specialMode is 'no' and

      @state.animation is 'fadeInDown' and
      _.isEmpty(@state.nodeAnimation) and

      _.isEmpty(@state.nodeArray) and
      _.isEmpty(@state.selectedArray) and

      @state.useSuggestedTag is yes and

      @state.currentNodeIndex is 0 and
      @state.currentPageIndex is 0 and

      @state.cache.input is '' and
      _.isEmpty(@state.cache.nodeArray) and
      _.isEmpty(@state.cache.selectedArray)

    @callAction('n_clearCache')

  # ------------------------------------------------------------
  # Helping functions for setting states

  callAction: (actionName, params) ->
    ActionMatch.findAction(actionName).apply(@, params)

  callHandlerHelper: (helperName, input) ->
    InputHandler[helperName].call(@, input)

  setDeepState: (state) ->
    _.forEach state, (val, key) =>
      if _.isPlainObject(val)
        state[key] = _.assign(@state[key], val)

    @setState(state)
