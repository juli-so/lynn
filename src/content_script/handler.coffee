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

  fast: (event) ->

  command: (event) ->
    input = event.target.value
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

  s_tag: (event) ->
    input = event.target.value
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

  s_editTag: (event) ->
    input = event.target.value
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

  addBookmarkHelper: (event) ->
    input = event.target.value
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

  s_addBookmark: (event) ->
    @callHandlerHelper('addBookmarkHelper', event)

  s_addMultipleBookmark: (event) ->
    @callHandlerHelper('addBookmarkHelper', event)

  s_addAllCurrentWindowBookmark: ->
    @callHandlerHelper('addBookmarkHelper', event)

  s_addAllWindowBookmark: ->
    @callHandlerHelper('addBookmarkHelper', event)

  s_addLinkBookmark: ->
    @callHandlerHelper('addBookmarkHelper', event)

  # ------------------------------------------------------------

  s_addGroup: (event) ->
    input = event.target.value
    @setState { input }
    
