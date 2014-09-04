# Intereactive actions, mostly confirmed by Special actions

I_Action =
  addBookmark: ->
    @setState
      specialMode: 'addBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      node = Util.tabToNode(message.current)

      @setState { nodeArray: [node] }

      Listener.listenOnce 'suggestTag',{ bookmark: node } , (message) =>
        node = _.assign(node, { suggestedTagArray: message.tagArray })
        @setState { nodeArray: [node] }

  addMultipleBookmark: ->
    @setState
      specialMode: 'addMultipleBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArray = Util.tabToNode(message.tabArray)

      @setState { nodeArray }

      requestObject = { bookmarkArray: nodeArray }
      Listener.listenOnce 'suggestTag', requestObject, (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

  addAllCurrentWindowBookmark: ->
    @setState
      specialMode: 'addAllCurrentWindowBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      currentWindowTabArray = message.currentWindowTabArray
      nodeArray = Util.tabToNode(currentWindowTabArray)
      selectedArray = [0...nodeArray.length]

      @setState { nodeArray, selectedArray }

      requestObject = { bookmarkArray: nodeArray }
      Listener.listenOnce 'suggestTag', requestObject, (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

  addAllWindowBookmark: ->
    @setState
      specialMode: 'addAllWindowBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArray = Util.tabToNode(message.tabArray)
      selectedArray = [0...nodeArray.length]

      @setState { nodeArray, selectedArray }

      requestObject = { bookmarkArray: nodeArray }
      Listener.listenOnce 'suggestTag', requestObject, (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

  # ------------------------------------------------------------

  addGroup: (groupName) ->
    @setState
      specialMode: 'addGroup'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      currentWindowTabArray = message.currentWindowTabArray
      nodeArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

  removeGroup: (groupName) ->
    if not _.isEmpty(groupName)
      Listener.listenOnce 'removeGroup', { groupName }, (message) ->
        Listener.listenOnce { request: 'getSyncStorage' },
          request: 'removeGroup'
          groupName: groupName

      Message.postMessage
        request: 'removeGroup'
        groupName: groupName

      @callAction('hide')
