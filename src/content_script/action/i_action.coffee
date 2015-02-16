# ---------------------------------------------------------------------------- #
#                                                                              #
# Intereactive actions, mostly confirmed by Special actions                    #
#                                                                              #
# ---------------------------------------------------------------------------- #

I_Action =

  # ------------------------------------------------------------
  # Add bookmarks
  # ------------------------------------------------------------

  addBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (msg) =>
      node = Util.tabToNode(msg.currTab)

      @setState { nodeArr: [node] }

      Listener.listenOnce 'suggestTag', { bookmark: node } , (msg) =>
        node = _.assign(node, { suggestedTagArr: msg.tagArr })
        @setState { nodeArr: [node] }

  addMultipleBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addMultipleBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (msg) =>
      nodeArr = Util.tabToNode(msg.currWinTabArr)

      @setState { nodeArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (msg) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = msg.tagArrArr[index]

        @setState { nodeArr }

  addAllCurrentWinBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addAllCurrentWinBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (msg) =>
      nodeArr = Util.tabToNode(msg.currWinTabArr)
      selectedArr = [0...nodeArr.length]

      @setState { nodeArr, selectedArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (msg) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = msg.tagArrArr[index]

        @setState { nodeArr }

  addAllWinBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'addAllWinBookmark'
      input: ''

    Listener.listenOnce 'queryTab', {}, (msg) =>
      nodeArr = Util.tabToNode(msg.allTabArr)
      selectedArr = [0...nodeArr.length]

      @setState { nodeArr, selectedArr }

      reqObj = { bookmarkArr: nodeArr }
      Listener.listenOnce 'suggestTag', reqObj, (msg) =>
        _.forEach nodeArr, (node, index) =>
          node.suggestedTagArr = msg.tagArrArr[index]

        @setState { nodeArr }

  # ------------------------------------------------------------

  # Depending whether -r flag is present
  # Load title from remote or current a.href
  addLinkBookmark: (args, flags) ->
    @callAction('n_storeCache')
  
    @callAction('n_hide', [no])

    $(document).bind 'click.addLinkBookmark', (e) =>
      e.preventDefault()
      $(document).unbind 'click.addLinkBookmark'

      @callAction('n_show')
      @setState
        mode: 'command'
        specialMode: 'addLinkBookmark'
        input: ''

      if _.contains(window.location.hostname, 'google.com')
        href = e.target.dataset.href
      else
        href = e.target.href

      if _.contains(flags, '-r')
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

            Listener.listenOnce 'suggestTag', { bookmark: node }, (msg) =>
              node = _.assign(node, { suggestedTagArr: msg.tagArr })
              @setState { nodeArr: [node] }
      else
        node =
          title: e.target.text
          url: e.target.href
          tagArr: []
          suggestedTagArr: []

        Listener.listenOnce 'suggestTag', { bookmark: node }, (msg) =>
          node = _.assign(node, { suggestedTagArr: msg.tagArr })
          @setState { nodeArr: [node] }

  # ------------------------------------------------------------

  h_addSelection: (selector = 'a', remote = no) ->
    @callAction('n_storeCache')

    @callAction('n_hide', [no])

    $(document).bind 'mouseup.addSelectionBookmark', (e) =>
      e.preventDefault()
      $(document).unbind 'mouseup.addSelectionBookmark'

      docFrag = document.getSelection().getRangeAt(0).cloneContents()
      linkArr = docFrag.querySelectorAll(selector)

      # Sometimes there is a strange function at the end of list
      linkArr = _.filter linkArr, (link) -> link.nodeName is 'A'

      if remote
        @callAction('n_show')
        @setState
          input: ''
          mode: 'command'
          specialMode: 'addSelectionBookmark'
          selectedArr: [0...linkArr.length]

        _.forEach linkArr, (link, index) =>
          $.ajax
            url: link.href
            success: (data) =>
              parser = new DOMParser()
              doc = parser.parseFromString(data, 'text/html')
              title = doc.getElementsByTagName('title')[0].text

              node =
                title: title
                url: link.href
                tagArr: []
                suggestedTagArr: []

              # No suggest tag now
              @setOneNode(index, node)
      else
        nodeArr = _.map linkArr, (link) ->
          title: link.text
          url: link.href
          tagArr: []
          suggestedTagArr: []

        @callAction('n_show')
        @setState
          input: ''
          mode: 'command'
          specialMode: 'addSelectionBookmark'
          nodeArr: nodeArr
          selectedArr: [0...nodeArr.length]

  # Depending whether -r flag is present
  # Load title from remote or current a.href
  addSelectionBookmark: (args, flags) ->
    @callAction('i_h_addSelection', ['a', _.contains(flags, '-r')])

  # ------------------------------------------------------------
  # Recover bookmarks
  # ------------------------------------------------------------

  recoverBookmark: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'recoverBookmark'
      input: ''

    Listener.listenOnce 'queryDeletedBookmark', {}, (msg) =>
      @setState { nodeArr: msg.nodeArr }

  # ------------------------------------------------------------
  # Delete bookmark
  # ------------------------------------------------------------

  deleteCurrentPageBookmark: ->
    @callAction('n_storeCache')

    Listener.listenOnce 'deleteCurrentPageBookmark', {}, (msg) =>
      if msg.nodeArr.length > 0
        @setState
          input: ''
          specialMode: 'deleteCurrentPageBookmark'
          nodeArr: msg.nodeArr
      else
        @callAction('n_reset')

  # ------------------------------------------------------------
  # Sessions
  # ------------------------------------------------------------

  storeWinSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeWinSession'
      input: ''

    # Visually display nodes, but save tabs to session
    Listener.listenOnce 'queryTab', {}, (msg) =>
      @setActionTmp('currWinTabArr', msg.currWinTabArr)

      nodeArr = _.map msg.currWinTabArr, (tab) ->
        title: tab.title
        url: tab.url
        tagArr: []

      Listener.listenOnce 'tagify', { nodeArr }, (msg) =>
        @setState { nodeArr: msg.nodeArr }

  storeChromeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'storeChromeSession'
      input: ''

    # Visually display nodes, but save tabs to session
    Listener.listenOnce 'queryTab', {}, (msg) =>
      @setActionTmp
        currWinId: msg.currTab.windowId
        allTabArr: msg.allTabArr

      nodeArr = _.map msg.allTabArr, (tab) ->
        title: tab.title
        url: tab.url
        tagArr: []

      Listener.listenOnce 'tagify', { nodeArr }, (msg) =>
        @setState { nodeArr: msg.nodeArr }

  removeSession: ->
    @callAction('n_storeCache')

    @setState
      specialMode: 'removeSession'
      input: ''

    Listener.listen 'searchSession', (msg) =>
      @setState { hint: msg.sessionRecord.name }
      nodeArr = _.flatten(msg.sessionRecord.session)

      Listener.listenOnce 'tagify', { nodeArr }, (msg) =>
        @setState { nodeArr: msg.nodeArr }

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
      # Separate input from current tags, if present
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

      input = commonTagArr.join(' ')
      if not _.isEmpty(commonTagArr)
        input += ' '

      nodeArr = @state.nodeArr
      _.forEach @state.selectedArr, (index) =>
        node = nodeArr[index]
        node.tagArr = _.difference(node.tagArr, commonTagArr)
        node.pendingTagArr = commonTagArr

      @setState
        input: input
        specialMode: 'editTag'
        nodeArr: nodeArr

  # ------------------------------------------------------------
  # Others
  # ------------------------------------------------------------

  # When inserting multiple bookmarks
  insertMarkDown: (args, flags) ->
    @callAction('n_storeCache')

    if @hasNoSelection()
      node = @getCurrentNode()

      @setState
        input: node.title
        specialMode: 'insertMarkDown'
        nodeArr: [node]

      @callAction('n_selectAllInput')
    else
      nodeArr = @getSelectedNodeArr()

      @setState
        input: ''
        specialMode: 'insertMarkDown'
        nodeArr: nodeArr
        selectedArr: [0...nodeArr.length]
