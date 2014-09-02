SpecialAction =
  confirm: ->
    @callAction('s_' + @state.specialMode)
    @callAction('hide')

  abort: ->
    @callAction('reset')
    @setState { mode: 'command' }

  # ------------------------------------------------------------

  tag: ->
    if _.isEmpty(@state.selectedArray)
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

  addBookmarkHelper: ->
    if _.isEmpty(@state.selectedArray)
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

  addGroup: ->
    groupName = @state.input.split(' ')[0]

    if not _.isEmpty(groupName)
      Listener.listenOnce 'addGroup', { groupName }, (message) ->
        Message.postMessage { request: 'getSyncStorage' }
