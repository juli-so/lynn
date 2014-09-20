# For all following methods
# When they get called, their @ refer to Lynn
InputHandler =
  matchHandler: (mode, specialMode) ->
    if specialMode is 'no'
      @[mode]
    else
      @['s_' + specialMode]

  # ------------------------------------------------------------

  query: (input) ->
    @callAction('n_clearInput')

    if input[-1..] is ':'
      @setDeepState
        input: ':'
        mode: 'command'
        cache:
          input: @state.input
    else
      @setState { input }

      Message.postMessage
        request: 'search'
        input: input

  fast: (input) ->

  command: (input) ->
    if input is '' or input[0] isnt ':'
      @callAction('n_clearInput')
      @setState
        input: input
        mode: 'query'

      Message.postMessage
        request: 'search'
        input: input
    else
      @setState { input }

  # ------------------------------------------------------------

  s_tag: (input) ->
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArray = @state.nodeArray

    if @hasNoSelection()
      nodeArray[@getCurrentNodeFullIndex()].pendingTagArray = tagArray
    else
      _.forEach @state.selectedArray, (selectedIndex) =>
        nodeArray[selectedIndex].pendingTagArray = tagArray

    @setState
      nodeArray: nodeArray
      input: input

  s_editTag: (input) ->
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArray = @state.nodeArray

    if @hasNoSelection()
      nodeArray[@getCurrentNodeFullIndex()].pendingTagArray = tagArray
    else
      _.forEach @state.selectedArray, (index) =>
        nodeArray[index].pendingTagArray = tagArray

    @setState
      nodeArray: nodeArray
      input: input

  # ------------------------------------------------------------

  addBookmarkHelper: (input) ->
    useSuggestedTag = input[0] isnt '!'

    # the '!' is also filtered if not using suggested tag
    tagArray = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # make the current tags in input field shown on node
    nodeArray = @state.nodeArray
    if @hasNoSelection()
      nodeArray[@getCurrentNodeFullIndex()].tagArray = tagArray
    else
      _.forEach @state.selectedArray, (selectedIndex) ->
        nodeArray[selectedIndex].tagArray = tagArray

    @setState { nodeArray, input, useSuggestedTag }

  s_addBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addMultipleBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addAllCurrentWindowBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addAllWindowBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addLinkBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  # ------------------------------------------------------------

  s_storeWindowSession: (input) ->
    @setState { input }
    
  s_removeWindowSession: (input) ->
    @setState { input }

    if _.isEmpty(input)
      @setState { nodeArray: [] }
    else
      Message.postMessage
        request: 'searchSession'
        input: input

  s_storeChromeSession: (input) ->
    @setState { input }
