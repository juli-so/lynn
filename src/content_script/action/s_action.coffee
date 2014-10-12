# Special Actions, mostly confirming Intereactive Actions

S_Action =

  # ------------------------------------------------------------
  # Bookmarks
  # ------------------------------------------------------------

  addBookmarkHelper: ->
    if @hasNoSelection()
      node = @getCurrentNode()

      if @state.useSuggestedTag
        tagArr = _.uniq(node.suggestedTagArr.concat(node.tagArr))
      else
        tagArr = node.tagArr

      Message.postMessage
        req: 'addBookmark'
        bookmark:
          title: node.title
          url: node.url
        tagArr: tagArr

    else
      _.forEach @getSelectedNodeArr(), (node) =>
        if @state.useSuggestedTag
          tagArr = _.uniq(node.suggestedTagArr.concat(node.tagArr))
        else
          tagArr = node.tagArr
        Message.postMessage
          req: 'addBookmark'
          bookmark:
            title: node.title
            url: node.url
          tagArr: tagArr

    @callAction('c_storeTag')
    @callAction('n_clearCache')

    # For multiple bookmark
    # Don't do 'if only one tag is inputted, search for it'
    if @state.specialMode is 'addMultipleBookmark'
      @callAction('n_hide')
    # Search for tags after bookmark is added
    else
      inputtedTagArr = _.filter @state.input.split(' '), (token) ->
        Util.isTag(token)

      @callAction('n_reset')
      input = inputtedTagArr.join(' ')
      @setState { input }

      Message.postMessage
        req: 'search'
        input: input

  addBookmark: ->
    @callAction('s_addBookmarkHelper')

  addMultipleBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllCurrentWinBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllWinBookmark: ->
    @callAction('s_addBookmarkHelper')

  addLinkBookmark: ->
    @callAction('s_addBookmarkHelper')

  addSelectionBookmark: ->
    @callAction('s_addBookmarkHelper')

  # ------------------------------------------------------------

  recoverBookmark: ->
    if @hasNoSelection()
      Message.postMessage
        req: 'recoverBookmark'
        index: @getCurrentNodeFullIndex()
    else
      Message.postMessage
        req: 'recoverBookmark'
        indexArr: @state.selectedArr

    currentNode = @getCurrentNode()
    @callAction('n_openHelper', [{ active: no }, no, no])

    @callAction('n_hide')

  # ------------------------------------------------------------
  # Tag
  # ------------------------------------------------------------

  tag: ->
    if @hasNoSelection()
      Message.postMessage
        req: 'addTag'
        node: @getCurrentNode()
    else
      Message.postMessage
        req: 'addTag'
        nodeArr: @getSelectedNodeArr()

    nodeArr = @state.nodeArr
    _.forEach nodeArr, (node) ->
      if not _.isEmpty(node.pendingTagArr)
        node.tagArr = node.tagArr.concat(node.pendingTagArr)
        node.pendingTagArr = []

    @setState { specialMode: 'no' }
    @callAction('n_clearCache')

  editTag: ->
    if @hasNoSelection()
      Message.postMessage
        req: 'editTag'
        node: @getCurrentNode()
    else
      Message.postMessage
        req: 'editTag'
        nodeArr: @getSelectedNodeArr()

    nodeArr = @state.nodeArr
    _.forEach nodeArr, (node) =>
      if not _.isEmpty(node.pendingTagArr)
        node.tagArr = node.tagArr.concat(node.pendingTagArr)
        node.pendingTagArr = []

    @setState { specialMode: 'no' }
    @callAction('n_clearCache')

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  storeWinSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName) and not CommandMap[sessionName]
      Listener.listenOnce 'storeWinSession', { sessionName }, (message) =>
        Message.postMessage { req: 'getSyncStor' }

        @callAction('n_hide')

  removeSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName)
      Listener.listenOnce 'removeSession', { sessionName }, (message) =>
        Message.postMessage { req: 'getSyncStor' }

        Listener.stopListen('searchSession')

        @callAction('n_hide')

  storeChromeSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName) and not CommandMap[sessionName]
      Listener.listenOnce 'storeChromeSession', { sessionName }, (message) =>
        Message.postMessage { req: 'getSyncStor' }

        @callAction('n_hide')

