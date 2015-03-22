# ---------------------------------------------------------------------------- #
#                                                                              #
# Special Actions, mostly confirming Intereactive Actions                      #
#                                                                              #
# ---------------------------------------------------------------------------- #

S_Action =

  # ------------------------------------------------------------
  # Bookmarks
  # ------------------------------------------------------------

  h_addBookmark: ->
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
    if @state.specialMode is 'addMultipleBookmark' or
       @state.specialMode is 'addSelectionBookmark'
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
    @callAction('s_h_addBookmark')

  addMultipleBookmark: ->
    @callAction('s_h_addBookmark')

  addAllCurrentWinBookmark: ->
    @callAction('s_h_addBookmark')

  addAllWinBookmark: ->
    @callAction('s_h_addBookmark')

  addLinkBookmark: ->
    @callAction('s_h_addBookmark')

  addSelectionBookmark: ->
    @callAction('s_h_addBookmark')

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
    @callAction('n_h_open', [{ active: no }, no, no])

    @callAction('n_hide')

  # ------------------------------------------------------------

  deleteCurrentPageBookmark: ->
    Message.postMessage
      req: 'removeBookmark'
      id: @getCurrentNode().id

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
      tabArr = @state.actionTmp['currWinTabArr']
      Listener.listenOnce 'storeWinSession', { sessionName, tabArr }, (message) =>
        @callAction('n_hide')

  storeChromeSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName) and not CommandMap[sessionName]
      tabArr    = @state.actionTmp['allTabArr']
      currWinId = @state.actionTmp['currWinId']

      msgObj = { sessionName, tabArr, currWinId }
      Listener.listenOnce 'storeChromeSession', msgObj, (message) =>
          @callAction('n_hide')

  removeSession: ->
    sessionName = @state.input.split(' ')[0]

    if not _.isEmpty(sessionName)
      Listener.listenOnce 'removeSession', { sessionName }, (message) =>
        Listener.stopListen('searchSession')

        @callAction('n_hide')

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  insertMarkDown: ->
    if @hasNoSelection()
      node = @state.nodeArr[0]
      mdText = "[#{@state.input}](#{node.url})"
    else
      # Reference style list
      if _.contains(@state.actionTmp['flags'], '-r')
        mdTextArr = _.map @state.nodeArr, (node, index) ->
          "[#{index + 1}]: #{node.url}"
        mdText = mdTextArr.join('\n')
      # Comma separated style
      else
        mdTextArr = _.map @state.nodeArr, (node, index) ->
          "[#{node.md || "link #{index + 1}"}](#{node.url})"
        mdText = mdTextArr.join(', ')


    mdText = mdText.trim()
    @callAction('n_hide')

    $(document).bind 'click.insertMarkDown', (e) =>
      e.preventDefault()
      $(document).unbind('click.insertMarkDown')

      element = e.target

      if element.nodeName is 'TEXTAREA' or 'INPUT'
        element.value += mdText

