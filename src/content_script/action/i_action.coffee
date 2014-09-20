# Intereactive actions, mostly confirmed by Special actions

I_Action =

  # ------------------------------------------------------------
  # Add bookmarks
  # ------------------------------------------------------------

  addBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      node = Util.tabToNode(message.current)

      @setState { nodeArray: [node] }

      Listener.listenOnce 'suggestTag', { bookmark: node } , (message) =>
        node = _.assign(node, { suggestedTagArray: message.tagArray })
        @setState { nodeArray: [node] }

  addMultipleBookmark: ->
    @callAction('n_storeCache')

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
    @callAction('n_storeCache')

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
    @callAction('n_storeCache')

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

  addLinkBookmark: ->
    @callAction('n_storeCache')
  
    @callAction('n_hide')

    $(document).click (e) =>
      e.preventDefault()
      $(document).unbind('click')

      @callAction('n_show')
      @setState
        mode: 'command'
        specialMode: 'addLinkBookmark'
        input: ''

      $.ajax
        url: e.target.href
        success: (data) =>
          console.log data
          parser = new DOMParser()
          doc = parser.parseFromString(data, 'text/html')
          title = doc.getElementsByTagName('title')[0].text

          # Recursively go up until reaching <a>
          element = e.target
          while element.nodeName isnt 'A'
            element = element.parentNode

          node =
            title: title
            url: element.href
            tagArray: []
            suggestedTagArray: []

          Listener.listenOnce 'suggestTag', { bookmark: node }, (message) =>
            node = _.assign(node, { suggestedTagArray: message.tagArray })
            @setState { nodeArray: [node] }


  # ------------------------------------------------------------
  # Recover bookmarks
  # ------------------------------------------------------------

  recoverBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'recoverBookmark'
      input: ''

    Listener.listenOnce 'queryDeletedBookmark', {}, (message) =>
      @setState { nodeArray: message.nodeArray }

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  storeWindowSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeWindowSession'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      currentWindowTabArray = message.currentWindowTabArray
      nodeArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

  storeChromeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeChromeSession'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArray = _.map message.tabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

  removeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'removeSession'
      input: ''

    Listener.listen 'searchSession', (message) =>
      if message.sessionRecord.type is 'window'
        @setState
          nodeArray: message.sessionRecord.session
      else
        @setState
          nodeArray: _.flatten(message.sessionRecord.session)

  # ------------------------------------------------------------
  # Tag
  # ------------------------------------------------------------

  tag: ->
    @callAction('n_storeCache')

    @setState
      input: ''
      specialMode: 'tag'

  editTag: ->
    @callAction('n_storeCache')

    if @hasNoSelection()
      nodeArray = @state.nodeArray
      currentNode = @getCurrentNode()

      input = @getCurrentNode().tagArray.join(' ') + ' '
      currentNode.pendingTagArray = currentNode.tagArray
      currentNode.tagArray = []

      nodeArray[@getCurrentNodeFullIndex()] = currentNode

      @setState
        input: input
        specialMode: 'editTag'
        nodeArray: nodeArray

    else
      selectedNodeArray = _.at(@state.nodeArray, @state.selectedArray)

      commonTagArray =
        _.intersection.apply(null, _.pluck(selectedNodeArray, 'tagArray'))

      input = commonTagArray.join(' ') + ' '

      nodeArray = @state.nodeArray
      _.forEach @state.selectedArray, (index) =>
        node = nodeArray[index]
        node.tagArray = _.difference(node.tagArray, commonTagArray)
        node.pendingTagArray = commonTagArray

      @setState
        input: input
        specialMode: 'editTag'
        nodeArray: nodeArray


