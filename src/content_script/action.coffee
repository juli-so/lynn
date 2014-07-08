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

      currentNodeIndex: 0
      currentPageIndex: 0

      pendingTagArray: []

      cache:
        input: ''
        pendingTagArray: []

  # ------------------------------------------------------------

  up: ->
    currentNodeIndex = \
      (@state.currentNodeIndex + @state.MAX_SUGGESTION_NUM - 1) %
        @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  down: ->
    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.MAX_SUGGESTION_NUM
    @setState { currentNodeIndex }

  # ------------------------------------------------------------

  pageUp: ->
    if @state.currentPageIndex > 0
      @setState
        currentPageIndex: @state.currentPageIndex - 1
        currentNodeIndex: 0

  pageDown: ->
    currentPageLastNodeIndex =
      (@state.currentPageIndex + 1) * @state.MAX_SUGGESTION_NUM
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
      @setState
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
      @setState
        mode: 'command'
        input: ':'
        cache:
          input: @state.input

  # ------------------------------------------------------------
  
  _openHelper: (option, newWindow, needHide) ->
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
    @callAction('_openHelper', [{ active:    yes }, no , yes])

  openInBackground: ->
    @callAction('_openHelper', [{ active:    no  }, no , no ])

  openInNewWindow: ->
    @callAction('_openHelper', [{ incognito: no  }, yes, yes])

  openInNewIncognitoWindow: ->
    @callAction('_openHelper', [{ incognito: yes }, yes, yes])

  # ------------------------------------------------------------

  test: ->
    console.log @getCurrentPageNodeArray()

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

# --------------------------------------------------------------
# --------------------------------------------------------------

# Map command to command actions
CommandMap =
  '1'             : 'c_one'

  'tag'           : 'c_tag'

  'a'             : 'c_addBookmark'
  'add'           : 'c_addBookmark'

  'am'            : 'c_addMultipleBookmark'
  'addMultiple'   : 'c_addMultipleBookmark'

  'aa'            : 'c_addAllBookmark'
  'addAll'        : 'c_addAllBookmark'

  's'             : 'c_storeTag'
  'sTag'          : 'c_storeTag'

# Command is entered and then executed
# If additional user-input is needed, enter specialMode
CommandAction =
  execute: ->
    if @state.input[0] isnt ':'
      return

    command = @state.input.split(' ')[0][1..]
    actionName = CommandMap[command]

    @callAction(actionName) if actionName

  # ------------------------------------------------------------

  one: ->
    Message.postMessage
      request: 'open'
      nodeArray: [
        { url: 'http://www.google.com' },
        { url: 'http://lodash.com/docs' }
      ]
      option:
        active: no

    @callAction('hide')

  # ------------------------------------------------------------

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

    Message.postMessage
      request: 'queryTab'
      queryInfo:
        active: yes
        currentWindow: yes

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

    Message.postMessage
      request: 'queryTab'
      queryInfo: {}

  addAllBookmark: ->
    @setState
      specialMode: 'addAllBookmark'
      input: ''

  # ------------------------------------------------------------

  storeTag: ->
    Message.postMessage
      request: 'storeTag'

# --------------------------------------------------------------
# --------------------------------------------------------------

SpecialAction =
  confirm: ->
    @callAction('s_' + @state.specialMode)
    @callAction('reset')

  abort: ->
    @setState
      input: ''

      specialMode: 'no'

      nodeArray: []
      selectedArray: []
      
      pendingTagArray: []

  # ------------------------------------------------------------

  tag: ->
    if _.isEmpty(@state.selectedArray)
      Message.postMessage
        request: 'addTag'
        node: @getCurrentNode()
        tagArray: @state.pendingTagArray
    else
      Message.postMessage
        request: 'addTag'
        nodeArray: @getSelectedNodeArray()
        tagArray: @state.pendingTagArray
    @setState
      input: ''
      pendingTagArray: []
    
  addBookmark: ->
    node = @state.nodeArray[0]
    Message.postMessage
      request: 'addBookmark'
      bookmark:
        title: node.title
        url: node.url
      tagArray: node.tagArray

    @callAction('c_storeTag')

  addMultipleBookmark: ->
    if _.isEmpty(@state.selectedArray)
      node = @getCurrentNode()
      Message.postMessage
        request: 'addBookmark'
        bookmark:
          title: node.title
          url: node.url
        tagArray: node.tagArray
    else
      _.forEach @getSelectedNodeArray(), (node) ->
        console.log node
        Message.postMessage
          request: 'addBookmark'
          bookmark:
            title: node.title
            url: node.url
          tagArray: node.tagArray

    @callAction('c_storeTag')
