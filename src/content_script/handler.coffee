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
      @setState
        input: ':'
        cachedInput: @state.input
        mode: 'command'

    @setState
      input: input
      currentNodeIndex: 0
      currentPageIndex: 0

    Message.postMessage
      request: 'search'
      input: event.target.value

  fast: (event) ->

  command: (event) ->
    @setState { input: input }

  s_tag: (event) ->
    input = event.target.value
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # make the current tags in input field show on node
    nodeArray = @state.nodeArray
    currentNode = @getCurrentNode()
    currentNode.tagArray = tagArray
    nodeArray[@getCurrentNodeIndex] = currentNode

    @setState { nodeArray, input }

  s_addBookmark: (event) ->
