# Special Actions, mostly confirming Intereactive Actions

S_Action =
  # ------------------------------------------------------------
  # Adding bookmarks
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
          tagArrayArray = node.tagArray
        Message.postMessage
          request: 'addBookmark'
          bookmark:
            title: node.title
            url: node.url
          tagArray: node.tagArray

    @callAction('c_storeTag')

    # For multiple bookmark
    # Don't do 'if only one tag is inputted, search for it'
    if @state.specialMode is 'addMultipleBookmark'
      @callAction('hide')
    # If the inputted tag is only one
    # Search for that tag after bookmark is added
    else
      inputtedTagArray = _.filter @state.input.split(' '), (token) ->
        Util.isTag(token)

      if inputtedTagArray.length is 1
        tag = inputtedTagArray[0]
        @callAction('n_reset')
        @setState { input: tag }
        Message.postMessage
          request: 'search'
          input: tag
      else
        @callAction('hide')


  addBookmark: ->
    @callAction('s_addBookmarkHelper')

  addMultipleBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllCurrentWindowBookmark: ->
    @callAction('s_addBookmarkHelper')

  addAllWindowBookmark: ->
    @callAction('s_addBookmarkHelper')

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

    @setState
      input: ''
      specialMode: 'no'

  editTag: ->
    if @hasNoSelection()
      Message.postMessage
        request: 'editTag'
        node: @getCurrentNode()
    else
      # haven't decided what to do

    nodeArray = @state.nodeArray
    _.forEach nodeArray, (node) ->
      if not _.isEmpty(node.pendingTagArray)
        node.tagArray = node.pendingTagArray
        node.pendingTagArray = []

    @setState
      input: ''
      specialMode: 'no'
      nodeArray: nodeArray

  # ------------------------------------------------------------

  addGroup: ->
    groupName = @state.input.split(' ')[0]

    if not _.isEmpty(groupName)
      Listener.listenOnce 'addGroup', { groupName }, (message) ->
        Message.postMessage { request: 'getSyncStorage' }

    @callAction('n_hide')
