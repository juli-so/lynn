# Special Actions, mostly confirming Intereactive Actions

S_Action =

  # ------------------------------------------------------------
  # Bookmarks
  # ------------------------------------------------------------

  addBookmarkHelper: ->
    if @hasNoSelection()
      node = @getCurrentNode()

      if @state.useSuggestedTag
        tagArray = _.uniq(node.suggestedTagArray.concat(node.tagArray))
      else
        tagArray = node.tagArray

      Message.postMessage
        request: 'addBookmark'
        bookmark:
          title: node.title
          url: node.url
        tagArray: tagArray

    else
      _.forEach @getSelectedNodeArray(), (node) =>
        if @state.useSuggestedTag
          tagArray = _.uniq(node.suggestedTagArray.concat(node.tagArray))
        else
          tagArray = node.tagArray
        Message.postMessage
          request: 'addBookmark'
          bookmark:
            title: node.title
            url: node.url
          tagArray: tagArray

    @callAction('c_storeTag')
    @callAction('n_clearCache')

    # For multiple bookmark
    # Don't do 'if only one tag is inputted, search for it'
    if @state.specialMode is 'addMultipleBookmark'
      @callAction('n_hide')
    # Search for tags after bookmark is added
    else
      inputtedTagArray = _.filter @state.input.split(' '), (token) ->
        Util.isTag(token)

      @callAction('n_reset')
      input = inputtedTagArray.join(' ')
      @setState { input }

      Message.postMessage
        request: 'search'
        input: input

  addBookmark: ->
    @callAction('s_addBookmarkHelper')

  addMultipleBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllCurrentWindowBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllWindowBookmark: ->
    @callAction('s_addBookmarkHelper')

  addLinkBookmark: ->
    @callAction('s_addBookmarkHelper')

  # ------------------------------------------------------------

  recoverBookmark: ->
    currentNode = @getCurrentNode()
    @callAction('n_openHelper', [{ active: no }, no, no])

    if @hasNoSelection()
      console.log @getCurrentNodeFullIndex()
      Message.postMessage
        request: 'recoverBookmark'
        index: @getCurrentNodeFullIndex()
    else
      Message.postMessage
        request: 'recoverBookmark'
        indexArray: @state.selectedArray

    @callAction('n_hide')

  # ------------------------------------------------------------
  # Tag
  # ------------------------------------------------------------

  tag: ->
    if @hasNoSelection()
      Message.postMessage
        request: 'addTag'
        node: @getCurrentNode()
    else
      Message.postMessage
        request: 'addTag'
        nodeArray: @getSelectedNodeArray()

    nodeArray = @state.nodeArray
    _.forEach nodeArray, (node) ->
      if not _.isEmpty(node.pendingTagArray)
        node.tagArray = node.tagArray.concat(node.pendingTagArray)
        node.pendingTagArray = []

    @setState { specialMode: 'no' }
    @callAction('n_clearCache')

  editTag: ->
    if @hasNoSelection()
      Message.postMessage
        request: 'editTag'
        node: @getCurrentNode()
    else
      Message.postMessage
        request: 'editTag'
        nodeArray: @getSelectedNodeArray()

    nodeArray = @state.nodeArray
    _.forEach nodeArray, (node) =>
      if not _.isEmpty(node.pendingTagArray)
        node.tagArray = node.tagArray.concat(node.pendingTagArray)
        node.pendingTagArray = []

    @setState { specialMode: 'no' }
    @callAction('n_clearCache')

  # ------------------------------------------------------------

  storeWindowSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName)
      Listener.listenOnce 'storeWindowSession', { sessionName }, (message) =>
        Message.postMessage { request: 'getSyncStorage' }

        @callAction('n_hide')

  removeWindowSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName)
      Listener.listenOnce 'removeWindowSession', { sessionName }, (message) =>
        Message.postMessage { request: 'getSyncStorage' }

        Listener.stopListen('searchSession')

        @callAction('n_hide')
