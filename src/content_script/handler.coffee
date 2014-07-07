Handler =
  matchHandler: (mode, specialMode) ->
    if specialMode is 'no'
      InputHandler[mode]
    else
      InputHandler['s_' + specialMode]

# For all following methods
# When they get called, their @ refer to Lynn
InputHandler =
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
