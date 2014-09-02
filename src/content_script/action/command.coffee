# Map command to command actions
CommandMap =
  'a'             : 'c_addBookmark'
  'am'            : 'c_addMultipleBookmark'
  'aa'            : 'c_addAllCurrentWindowBookmark'
  'aA'            : 'c_addAllWindowBookmark'

  'g'             : 'c_addGroup'
  'ug'            : 'c_removeGroup'

  's'             : 'c_storeTag'

  'l'             : 'c_lastWindow'

# Command is entered and then executed
# If additional user-input is needed, enter specialMode
CommandAction =
  execute: ->
    if @state.input[0] isnt ':'
      return

    command = @state.input.split(' ')[0][1..]
    args = @state.input.split(' ')[1..]

    if CommandMap[command]
      @callAction(CommandMap[command], args)
    else if @state.groupMap[command]
      # Custom group actions
      nodeArray = @state.groupMap[command]

      Message.postMessage
        request: 'open'
        option:
          active: no
        nodeArray: nodeArray

      @callAction('hide')

  # ------------------------------------------------------------

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
        Message.listenOnce { request: 'getSyncStorage' },
          request: 'removeGroup'
          groupName: groupName

      Message.postMessage
        request: 'removeGroup'
        groupName: groupName

      @callAction('hide')
    
  # ------------------------------------------------------------

  storeTag: ->
    Message.postMessage
      request: 'storeTag'
    @callAction('hide')

  # ------------------------------------------------------------

  lastWindow: ->
    Message.postMessage
      request: 'lastWindow'
    @callAction('hide')
