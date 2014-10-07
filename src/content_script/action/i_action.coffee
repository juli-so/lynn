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

      @setState { nodeArr: [node] }

      Listener.listenOnce 'suggestTag', { bookmark: node } , (message) =>
        node = _.assign(node, { suggestedTagArr: message.tagArr })
        @setState { nodeArr: [node] }

  addMultipleBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addMultipleBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArr = Util.tabToNode(message.tabArr)

      @setState { nodeArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (message) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = message.tagArrArr[index]

        @setState { nodeArr }

  addAllCurrentWinBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addAllCurrentWinBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      currentWinTabArr = message.currentWinTabArr
      nodeArr = Util.tabToNode(currentWinTabArr)
      selectedArr = [0...nodeArr.length]

      @setState { nodeArr, selectedArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (message) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = message.tagArrArr[index]

        @setState { nodeArr }

  addAllWinBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addAllWinBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArr = Util.tabToNode(message.tabArr)
      selectedArr = [0...nodeArr.length]

      @setState { nodeArr, selectedArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (message) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = message.tagArrArr[index]

        @setState { nodeArr }

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

      if _.contains(window.location.hostname, 'google.com')
        href = e.target.dataset.href
      else
        href = e.target.href

      $.ajax
        url: href
        success: (data) =>
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
            tagArr: []
            suggestedTagArr: []

          Listener.listenOnce 'suggestTag', { bookmark: node }, (message) =>
            node = _.assign(node, { suggestedTagArr: message.tagArr })
            @setState { nodeArr: [node] }

        @setState { nodeArr: [node] }

  # ------------------------------------------------------------
  # Recover bookmarks
  # ------------------------------------------------------------

  recoverBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'recoverBookmark'
      input: ''

    Listener.listenOnce 'queryDeletedBookmark', {}, (message) =>
      @setState { nodeArr: message.nodeArr }

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  storeWinSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeWinSession'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      currentWinTabArr = message.currentWinTabArr
      nodeArr = _.map currentWinTabArr, (tab) ->
        title: tab.title
        url: tab.url
        tagArr: []

      @setState { nodeArr }

  storeChromeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeChromeSession'
      input: ''

    Listener.listenOnce 'queryTab', {}, (message) =>
      nodeArr = _.map message.tabArr, (tab) ->
        title: tab.title
        url: tab.url
        tagArr: []

      @setState { nodeArr }

  removeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'removeSession'
      input: ''

    Listener.listen 'searchSession', (message) =>
      if message.sessionRecord.type is 'window'
        @setState
          nodeArr: message.sessionRecord.session
      else
        @setState
          nodeArr: _.flatten(message.sessionRecord.session)

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
      nodeArr = @state.nodeArr
      currentNode = @getCurrentNode()

      input = @getCurrentNode().tagArr.join(' ')
      if not _.isEmpty(@getCurrentNode().tagArr)
        input += ' '

      currentNode.pendingTagArr = currentNode.tagArr
      currentNode.tagArr = []

      nodeArr[@getCurrentNodeFullIndex()] = currentNode

      @setState
        input: input
        specialMode: 'editTag'
        nodeArr: nodeArr

    else
      selectedNodeArr = _.at(@state.nodeArr, @state.selectedArr)

      commonTagArr =
        _.intersection.apply(null, _.pluck(selectedNodeArr, 'tagArr'))

      input = commonTagArr.join(' ') + ' '

      nodeArr = @state.nodeArr
      _.forEach @state.selectedArr, (index) =>
        node = nodeArr[index]
        node.tagArr = _.difference(node.tagArr, commonTagArr)
        node.pendingTagArr = commonTagArr

      @setState
        input: input
        specialMode: 'editTag'
        nodeArr: nodeArr
