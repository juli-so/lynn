# ---------------------------------------------------------------------------- #
#                                                                              #
# Main App                                                                     #
#                                                                              #
# ---------------------------------------------------------------------------- #

{ div, span } = React.DOM

Lynn = React.createClass
  getInitialState: ->
    visible: no
    input: ''

    mode: 'query' # query | fast | command
    # in special mode, mode and nodeArr change won't be triggered
    # when 'no' it is disabled
    specialMode: 'no'

    # when 'no' animation is disabled
    animation: 'fadeInDown'
    # nodeIndex -> animation string
    nodeAnimation: {}

    nodeArr: []
    selectedArr: []
    synoTagArr: []

    useSuggestedTag: yes

    currentNodeIndex: 0
    currentPageIndex: 0

    cache:
      input: ''
      nodeArr: []
      selectedArr: []

    # loaded from storage
    option:
      MAX_SUGGESTION_NUM: 8

    sessionMap: {}
    synoTagRecordArr: []

  componentWillMount: ->
    Listener.listen 'search', (message) =>
      @setState nodeArr: message.result

    Listener.listen 'getSyncStor', (message) =>
      @setState
        option: message.storObj.option || @state.option
        sessionMap: message.storObj.sessionMap || @state.sessionMap
        synoTagRecordArr:
          message.storObj.synoTagRecordArr || @state.synoTagRecordArr

    Message.postMessage { req: 'getSyncStor' }

    # keydown events
    $(window).keydown (event) =>
      # Global invoke
      if ActionMatch.isInvoked(event)
        @callAction('n_toggle')

      else
        # Shortcut when lynn is shown
        if @state.visible
          actionName = ActionMatch.findActionName(event, @state.mode, @state.specialMode)
          if actionName isnt 'noop'
            event.preventDefault()
            event.stopPropagation()

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

        nodeArr: @state.nodeArr
        selectedArr: @state.selectedArr

        useSuggestedTag: @state.useSuggestedTag

        currentNodeIndex: @state.currentNodeIndex
        currentPageIndex: @state.currentPageIndex

      Bot
        input: @state.input

        mode: @state.mode
        specialMode: @state.specialMode

        nodeArr: @state.nodeArr
        selectedArr: @state.selectedArr

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
    @state.nodeArr[@getCurrentNodeFullIndex()]

  getSelectedNodeArr: ->
    _.at(@state.nodeArr, @state.selectedArr)

  getNodeIndexStart: ->
    @state.currentPageIndex * @state.option.MAX_SUGGESTION_NUM

  getNodeIndexEnd: ->
    start = @getNodeIndexStart()
    Math.min(@state.nodeArr.length, start + @state.option.MAX_SUGGESTION_NUM)

  getCurrentPageNodeArr: ->
    @state.nodeArr[@getNodeIndexStart()...@getNodeIndexEnd()]

  hasNoSelection: ->
    _.isEmpty(@state.selectedArr)

  hasSelection: ->
    not @hasNoSelection()

  isResetted: ->
    return yes and
      @state.input is '' and

      @state.mode is 'query' and
      @state.specialMode is 'no' and

      @state.animation is 'fadeInDown' and
      _.isEmpty(@state.nodeAnimation) and

      _.isEmpty(@state.nodeArr) and
      _.isEmpty(@state.selectedArr) and

      @state.useSuggestedTag is yes and

      @state.currentNodeIndex is 0 and
      @state.currentPageIndex is 0 and

      @state.cache.input is '' and
      _.isEmpty(@state.cache.nodeArr) and
      _.isEmpty(@state.cache.selectedArr)

    @callAction('n_clearCache')

  # ------------------------------------------------------------
  # Helping functions for setting states

  callAction: (actionName, args) ->
    ActionMatch.findAction(actionName).apply(@, args)

  callHandlerHelper: (helperName, input) ->
    InputHandler[helperName].call(@, input)

  setDeepState: (state) ->
    _.forEach state, (val, key) =>
      if _.isPlainObject(val)
        state[key] = _.assign(@state[key], val)

    @setState(state)

  setOneNode: (index, node) ->
    nodeArr = @state.nodeArr
    nodeArr[index] = node
    @setState { nodeArr }