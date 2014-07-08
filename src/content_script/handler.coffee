# For all following methods
# When they get called, their @ refer to Lynn
InputHandler =
  matchHandler: (mode, specialMode) ->
    if specialMode is 'no'
      @[mode]
    else
      @['s_' + specialMode]

  # ------------------------------------------------------------

  query: (event) ->
    input = event.target.value
    if input[-1..] is ':'
      @setDeepState
        input: ':'
        mode: 'command'
        cache:
          input: @state.input
      return

    @setState
      input: input
      currentNodeIndex: 0
      currentPageIndex: 0
      selectedArray: []

    Message.postMessage
      request: 'search'
      input: event.target.value

  fast: (event) ->

  command: (event) ->
    input = event.target.value
    @setState { input: input }

  # ------------------------------------------------------------

  s_tag: (event) ->
    input = event.target.value
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    @setState
      pendingTagArray: tagArray
      input: input

  s_addBookmark: (event) ->
    input = event.target.value
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # make the current tags in input field shown on node
    nodeArray = @state.nodeArray
    nodeArray[0].tagArray = tagArray

    @setState { nodeArray, input }

  s_addMultipleBookmark: ->
    input = event.target.value
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # make the current tags in input field shown on node
    nodeArray = @state.nodeArray
    if _.isEmpty(@state.selectedArray)
      nodeArray[@getCurrentNodeIndex()].tagArray = tagArray
    else
      _.forEach @state.selectedArray, (selectedIndex) ->
        nodeArray[selectedIndex].tagArray = tagArray

    @setState { nodeArray, input }
