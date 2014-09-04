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
    
  # ------------------------------------------------------------

  addGroup: ->
    groupName = @state.input.split(' ')[0]

    if not _.isEmpty(groupName)
      Listener.listenOnce 'addGroup', { groupName }, (message) ->
        Message.postMessage { request: 'getSyncStorage' }
