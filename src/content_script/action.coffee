Action =
  # match actionName to real action function
  matchAction: (actionName) ->
    switch actionName[0..1]
      when 'q_' then QueryAction[actionName[2..]]
      when 'f_' then FastAction[actionName[2..]]
      when 'c_' then CommandAction[actionName[2..]]
      when 's_' then SpecialAction[actionName[2..]]
      else CommonAction[actionName]

# --------------------------------------------------------------
# --------------------------------------------------------------

# For all following methods
# When they get called, their @ refer to Lynn
CommonAction =
  noop: _.noop

  print: ->
    console.log @state
  
  # ------------------------------------------------------------

  hide: ->
    @setState { animation: 'fadeOutUp' }

    timeOutFunc = =>
      @setState { visible: no }
      @callAction('reset')

    setTimeout(timeOutFunc, 200)

  show: ->
    @setState
      visible: yes
      animation: 'fadeInDown'

  toggle: ->
    if @state.visible
      @callAction('hide')
    else
      @callAction('show')

  reset: ->
    @setDeepState
      input: ''

      mode: 'query'
      specialMode: 'no'

      nodeArray: []
      selectedArray: []

      useSuggestedTag: yes

      currentNodeIndex: 0
      currentPageIndex: 0

      cache:
        input: ''
        selectedArray: []

  resetSearchResult: ->
    @setState
      nodeArray: []
      selectedArray: []

      currentNodeIndex: 0
      currentPageIndex: 0

  # ------------------------------------------------------------

  up: ->
    currentNodeIndex = \
      (@state.currentNodeIndex + @state.option.MAX_SUGGESTION_NUM - 1) %
        @state.option.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  down: ->
    currentNodeIndex = (@state.currentNodeIndex + 1) %
      @state.option.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  # ------------------------------------------------------------

  pageUp: ->
    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    currentPageLastNodeIndex =
      (@state.currentPageIndex + 1) * @state.option.MAX_SUGGESTION_NUM
    if currentPageLastNodeIndex < @state.nodeArray.length
      @setState
        currentPageIndex: @state.currentPageIndex + 1
        currentNodeIndex: 0
      
  # ------------------------------------------------------------

  nextMode: ->
    if @state.mode is 'query'
      @setState { mode: 'fast' }
    else if @state.mode is 'fast'
      @setDeepState
        mode: 'command'
        input: ':'
        cache:
          input: @state.input
    else
      @setDeepState
        mode: 'query'
        input: @state.cache.input
        cache:
          input: ''

  prevMode: ->
    if @state.mode is 'fast'
      @setState { mode: 'query' }
    else if @state.mode is 'command'
      @setState
        mode: 'fast'
        input: @state.cache.input
        cache:
          input: ''
    else
      @setDeepState
        mode: 'command'
        input: ':'
        cache:
          input: @state.input

  # ------------------------------------------------------------
  
  openHelper: (option, newWindow, needHide) ->
    message =
      request: if newWindow then 'openInNewWindow' else 'open'
      option: option

    if _.isEmpty(@state.selectedArray)
      message['node'] = @getCurrentNode()
    else
      message['nodeArray'] = @getSelectedNodeArray()

    Message.postMessage(message)
    if needHide then @callAction('hide')

  open: ->
    @callAction('openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('openHelper', [{ active:    no  }, no , no ])

  openInNewWindow: ->
    @callAction('openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWindow: ->
    @callAction('openHelper', [{ incognito: yes }, yes, yes])

  # ------------------------------------------------------------

  test: ->
    console.log @getCurrentNodeIndex()

# --------------------------------------------------------------
# --------------------------------------------------------------

QueryAction =

# --------------------------------------------------------------
# --------------------------------------------------------------

FastAction =
  select: ->
    unless _.contains(@state.selectedArray, @getCurrentNodeIndex())
      selectedArray = _.union(@state.selectedArray, [@getCurrentNodeIndex()])
      @setState { selectedArray }

  unselect: ->
    if _.contains(@state.selectedArray, @getCurrentNodeIndex())
      selectedArray = _.without(@state.selectedArray, @getCurrentNodeIndex())
      @setState { selectedArray }

  # ------------------------------------------------------------

  selectAllInCurrentPage: ->
    newlySelected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.union(@state.selectedArray, newlySelected)
    @setState { selectedArray }

  selectAll: ->
    @setState { selectedArray: [0...@state.nodeArray.length] }

  unselectAllInCurrentPage: ->
    newlyUnselected = [@getNodeIndexStart()...@getNodeIndexEnd()]
    selectedArray = _.difference(@state.selectedArray, newlyUnselected)
    @setState { selectedArray }

  unselectAll: ->
    @setState { selectedArray: [] }

  toggleAllSelectionInCurrentPage: ->
    currentPageNodeIndexArray = []
    if _.every([@getNodeIndexStart()...@getNodeIndexEnd()],
        (index) => _.contains(@state.selectedArray, index))
      @callAction('f_unselectAllInCurrentPage')
    else
      @callAction('f_selectAllInCurrentPage')

  toggleAll: ->
    if @state.selectedArray.length is @state.nodeArray.length
      @callAction('f_unselectAll')
    else
      @callAction('f_selectAll')

  # ------------------------------------------------------------

  tag: ->
    @setState
      specialMode: 'tag'
      input: ''

  # ------------------------------------------------------------

  remove: ->
    if @state.nodeArray.length isnt 0
      # index within all nodeArray, not within current page nodes
      currentNodeFullIndex = @getCurrentNodeIndex()
      nodeAnimation = {}
      nodeAnimation[currentNodeFullIndex] = 'fadeOutRight'
      @setState { nodeAnimation }

      # remove bookmark from screen using animation
      timeOutFunc = =>
        nodeArray = @state.nodeArray
        nodeArray = _.without(nodeArray, nodeArray[currentNodeFullIndex])

        # if the current selected node is the last one
        # let it still point to the last node after one node is removed
        if currentNodeFullIndex is nodeArray.length
          if @state.currentNodeIndex is 0
            currentNodeIndex = @state.option.MAX_SUGGESTION_NUM - 1
            currentPageIndex = @state.currentPageIndex - 1
          else
            currentNodeIndex = @state.currentNodeIndex - 1
            currentPageIndex = @state.currentPageIndex

          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

            currentNodeIndex: currentNodeIndex
            currentPageIndex: currentPageIndex
        else
          @setState
            nodeArray: nodeArray
            nodeAnimation: {}

        @callAction('reset') if _.isEmpty(@state.nodeArray)

      setTimeout(timeOutFunc, 350)

      # really remove the bookmark in DB
      Message.postMessage
        request: 'removeBookmark'
        id: @getCurrentNode().id

# --------------------------------------------------------------
# --------------------------------------------------------------

# Map command to command actions
CommandMap =
  'a'             : 'c_addBookmark'
  'am'            : 'c_addMultipleBookmark'
  'aa'            : 'c_addAllCurrentWindowBookmark'
  'aA'            : 'c_addAllWindowBookmark'

  'g'             : 'c_addGroup'
  'ug'            : 'c_removeGroup'

  's'             : 'c_storeTag'

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

  _tabToNode: (tabOrTabArray) ->
    if _.isArray(tabOrTabArray)
      tabArray = tabOrTabArray
      _.map tabOrTabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []
    else
      tab = tabOrTabArray
      title: tab.title
      url: tab.url
      tagArray: []

  addBookmark: ->
    @setState
      specialMode: 'addBookmark'
      input: ''

    Listener.setOneTimeListener 'queryTab', (message) =>
      node =
        title: message.current.title
        url: message.current.url
        tagArray: []

      @setState { nodeArray: [node] }

      Listener.setOneTimeListener 'suggestTag', (message) =>
        node = _.assign(node, { suggestedTagArray: message.tagArray })
        @setState { nodeArray: [node] }

      Message.postMessage
        request: 'suggestTag'
        bookmark: node

    Message.postMessage { request: 'queryTab' }

  addMultipleBookmark: ->
    @setState
      specialMode: 'addMultipleBookmark'
      input: ''

    Listener.setOneTimeListener 'queryTab', (message) =>
      nodeArray = _.map message.tabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

      Listener.setOneTimeListener 'suggestTag', (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

      Message.postMessage
        request: 'suggestTag'
        bookmarkArray: nodeArray

    Message.postMessage { request: 'queryTab' }

  addAllCurrentWindowBookmark: ->
    @setState
      specialMode: 'addAllCurrentWindowBookmark'
      input: ''

    Listener.setOneTimeListener 'queryTab', (message) =>
      currentWindowTabArray = message.currentWindowTabArray
      nodeArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

      Listener.setOneTimeListener 'suggestTag', (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

      Message.postMessage
        request: 'suggestTag'
        bookmarkArray: nodeArray

    Message.postMessage { request: 'queryTab' }

  addAllWindowBookmark: ->
    @setState
      specialMode: 'addAllWindowBookmark'
      input: ''

    Listener.setOneTimeListener 'queryTab', (message) =>
      nodeArray = _.map message.tabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

      Listener.setOneTimeListener 'suggestTag', (message) =>
        _.forEach nodeArray, (node, index) =>
          node.suggestedTagArray = message.tagArrayArray[index]

        @setState { nodeArray }

      Message.postMessage
        request: 'suggestTag'
        bookmarkArray: nodeArray

    Message.postMessage { request: 'queryTab' }

  # ------------------------------------------------------------

  addGroup: (groupName) ->
    @setState
      specialMode: 'addGroup'
      input: ''

    Listener.setOneTimeListener 'queryTab', (message) =>
      currentWindowTabArray = message.currentWindowTabArray
      nodeArray = _.map currentWindowTabArray, (tab) ->
        title: tab.title
        url: tab.url
        tagArray: []

      @setState { nodeArray }

    Message.postMessage { request: 'queryTab' }

  removeGroup: (groupName) ->
    if not _.isEmpty(groupName)
      Listener.setOneTimeListener 'removeGroup', (message) ->
        Message.postMessage { request: 'getSyncStorage' },
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

# --------------------------------------------------------------
# --------------------------------------------------------------

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
      Listener.setOneTimeListener 'addGroup', (message) ->
        Message.postMessage { request: 'getSyncStorage' }

      Message.postMessage
        request: 'addGroup'
        groupName: groupName
