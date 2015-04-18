# ---------------------------------------------------------------------------- #
#                                                                              #
# Handler for input in different modes                                         #
#                                                                              #
# ---------------------------------------------------------------------------- #

InputHandler =

  # ------------------------------------------------------------
  # Used for matching correct handler
  # @ here refers to InputHandler
  # ------------------------------------------------------------

  default: (input) ->
    @setState { input }

  matchHandler: (mode, specialMode) ->
    if specialMode is 'no'
      @[mode] || @default
    else
      @['s_' + specialMode] || @default

  # ------------------------------------------------------------
  # Handlers
  # * When they get called, their @ refer to Lynn
  # ------------------------------------------------------------

  query: (input) ->
    @callAction('n_clearInput')

    if input[-1..] is ':'
      @callAction('n_storeCache')

      nodeArr = @state.nodeArr

      @setDeepState
        input: ':'
        mode: 'command'
        cache:
          input: @state.input

      @setState { nodeArr }

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
      command = input[1..].split(' ')[0]
      if not _.isEmpty(command)
        sessionRecord = _.find @state.sessionMap, (s, sName) ->
          _.startsWith(sName, command)

      if not CommandMap[command] and sessionRecord
        @setState
          input: input
          hint: ':' + sessionRecord.name
      else
        @setState
          input: input
          hint: ''

  # ------------------------------------------------------------

  s_tag: (input) ->
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArr = @state.nodeArr

    if @hasNoSelection()
      # Remove dups
      currentTagArr = nodeArr[@getCurrentNodeFullIndex()].tagArr
      tagArrToAdd = _.filter tagArr, (tag) -> tag not in currentTagArr

      nodeArr[@getCurrentNodeFullIndex()].pendingTagArr = tagArrToAdd
    else
      _.forEach @state.selectedArr, (selectedIndex) =>
        # Remove dups
        tagArrToAdd = _.filter tagArr, (tag) ->
          tag not in nodeArr[selectedIndex].tagArr
        nodeArr[selectedIndex].pendingTagArr = tagArrToAdd

    @setState
      nodeArr: nodeArr
      input: input

  s_editTag: (input) ->
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)
    nodeArr = @state.nodeArr

    if @hasNoSelection()
      # Remove dups
      currentTagArr = nodeArr[@getCurrentNodeFullIndex()].tagArr
      tagArrToAdd = _.filter tagArr, (tag) -> tag not in currentTagArr

      nodeArr[@getCurrentNodeFullIndex()].pendingTagArr = tagArrToAdd
    else
      _.forEach @state.selectedArr, (index) =>
        # Remove dups
        tagArrToAdd = _.filter tagArr, (tag) ->
          tag not in nodeArr[index].tagArr
        nodeArr[index].pendingTagArr = tagArrToAdd

    @setState
      nodeArr: nodeArr
      input: input

  # ------------------------------------------------------------

  s_editBookmarkTitle: (input) ->
    if @hasNoSelection()
      nodeArr = @state.nodeArr
      nodeArr[@getCurrentNodeFullIndex()].title = input

    @setState { nodeArr, input }
  
  # ------------------------------------------------------------

  # When using '!', ignore suggested tags
  h_addBookmark: (input) ->
    useSuggestedTag = input[0] isnt '!'

    # '!' is also filtered when not using suggested tag
    tagArr = _.filter input.split(' '), (token) ->
      Util.isTag(token)

    # Make the current tags in input field shown on node
    nodeArr = @state.nodeArr
    if @hasNoSelection()
      nodeArr[@getCurrentNodeFullIndex()].tagArr = tagArr
    else
      _.forEach @state.selectedArr, (selectedIndex) ->
        nodeArr[selectedIndex].tagArr = tagArr

    @setState { nodeArr, input, useSuggestedTag }

  s_addBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  s_addMultipleBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  s_addAllCurrentWinBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  s_addAllWinBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  s_addLinkBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  s_addSelectionBookmark: (input) ->
    @callHandlerHelper('h_addBookmark', input)

  # ------------------------------------------------------------

  s_removeSession: (input) ->
    @setState { input }

    if _.isEmpty(input)
      @setState { nodeArr: [] }
    else
      Message.postMessage
        req: 'searchSession'
        input: input

  # ------------------------------------------------------------

  s_insertMarkDown: (input) ->
    @setState { input }

    if @hasSelection()
      nodeArr = @state.nodeArr

      if input is ''
        _.forEach nodeArr, (node, index) ->
          node.md = "link #{index + 1}"

        @setState { nodeArr }
      else
        if _.contains(input, ',')
          tokenArr = input.split(',')
        else
          tokenArr = input.split(' ')

        _.forEach nodeArr, (node, index) ->
          node.md = tokenArr[index].trim() || "link #{index + 1}"

        @setState { nodeArr }
