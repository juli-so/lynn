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

    if @props.specialMode
      inputPlaceHolderMap =
        'tag'                        : 'Enter your tag here'
        'addBookmark'                : 'Enter your tag here'
        'addMultipleBookmark'        : 'Enter your tag here'
        'addAllCurrentWindowBookmark': 'Enter your tag here'
        'addAllWindowBookmark'       : 'Enter your tag here'
        'addGroup'                   : 'Enter name of your group here'

      inputPlaceHolder = inputPlaceHolderMap[@props.specialMode]
    else
      inputPlaceHolder = switch @props.mode
        when 'query' then 'Search for...'
        when 'fast' then 'Invoke fast command!'
        when 'command' then 'Your command...'

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
    div { id: 'lynn_mid' },
      _.map @props.nodeArray[@props.start...@props.end], (node, index) =>
        animation = @props.nodeAnimation[index] || 'fadeInDown'

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

# lynn_bot

Bot = React.createClass
  render: ->
    numToString = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten']

    groupName = @props.input.split(' ')[0]

    specialModeStringMap =
      'tag'                        : 'Tag'
      'addBookmark'                : 'Add Bookmark'
      'addMultipleBookmark'        : 'Add multiple Bookmark'
      'addAllCurrentWindowBookmark': 'Add all tabs in current window 
                                      as Bookmark'
      'addAllWindowBookmark'       : 'Add all open tabs as Bookmark'
      'addGroup'                   : 'Add these bookmarks to group: ' +
                                      groupName

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
    # nodeIndex -> animation string
    nodeAnimation: {}

    nodeArray: []
    selectedArray: []

    useSuggestedTag: yes

    currentNodeIndex: 0
    currentPageIndex: 0

    cache:
      input: ''
      selectedArray: []

    # loaded from storage
    option:
      MAX_SUGGESTION_NUM: 8

    groupMap: {}

  componentWillMount: ->
    Listener.listen 'search', (message) =>
      @setState nodeArray: message.result

    Listener.listen 'getSyncStorage', (message) =>
      @setState
        option: message.storageObject.option || @state.option
        groupMap: message.storageObject.groupMap || @state.groupMap

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
          console.log actionName
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
    handler.call(@, event) if handler

  # ------------------------------------------------------------
  # helper functions for getting data

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

  # ------------------------------------------------------------
  # helping functions for setting states

  callAction: (actionName, params) ->
    ActionMatch.findAction(actionName).apply(@, params)

  callHandlerHelper: (helperName, event) ->
    InputHandler[helperName].call(@, event)

  setDeepState: (state) ->
    _.forEach state, (val, key) =>
      if _.isPlainObject(val)
        state[key] = _.assign(@state[key], val)

    @setState(state)
