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
        req: 'search'
        input: input

  fast: (input) ->

  command: (input) ->
    if input is '' or input[0] isnt ':'
      @callAction('n_clearInput')
      @setState
        input: input
        mode: 'query'

      Message.postMessage
        req: 'search'
        input: input
    else
      @setState { input }

  # ------------------------------------------------------------

  s_tag: (input) ->
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArr = @state.nodeArr

    if @hasNoSelection()
      nodeArr[@getCurrentNodeFullIndex()].pendingTagArr = tagArr
    else
      _.forEach @state.selectedArr, (selectedIndex) =>
        nodeArr[selectedIndex].pendingTagArr = tagArr

    @setState
      nodeArr: nodeArr
      input: input

  s_editTag: (input) ->
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArr = @state.nodeArr

    if @hasNoSelection()
      nodeArr[@getCurrentNodeFullIndex()].pendingTagArr = tagArr
    else
      _.forEach @state.selectedArr, (index) =>
        nodeArr[index].pendingTagArr = tagArr

    @setState
      nodeArr: nodeArr
      input: input

  # ------------------------------------------------------------

  addBookmarkHelper: (input) ->
    useSuggestedTag = input[0] isnt '!'

    # the '!' is also filtered if not using suggested tag
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # make the current tags in input field shown on node
    nodeArr = @state.nodeArr
    if @hasNoSelection()
      nodeArr[@getCurrentNodeFullIndex()].tagArr = tagArr
    else
      _.forEach @state.selectedArr, (selectedIndex) ->
        nodeArr[selectedIndex].tagArr = tagArr

    @setState { nodeArr, input, useSuggestedTag }

  s_addBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addMultipleBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addAllCurrentWinBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addAllWinBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  s_addLinkBookmark: (input) ->
    @callHandlerHelper('addBookmarkHelper', input)

  # ------------------------------------------------------------

  s_storeWinSession: (input) ->
    @setState { input }
    
  s_storeChromeSession: (input) ->
    @setState { input }

  s_removeSession: (input) ->
    @setState { input }

    if _.isEmpty(input)
      @setState { nodeArr: [] }
    else
      Message.postMessage
        req: 'searchSession'
        input: input
