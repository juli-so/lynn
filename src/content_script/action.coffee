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
    @callAction('reset')
    @setState { visible: no }

  show: ->
    @setState { visible: yes }
    $('.lynn_console').focus()

  toggle: ->
    if @state.visible
      @callAction('hide')
    else
      @callAction('show')

  reset: ->
    @setState
      input: ''
      cachedInput: ''
      mode: 'query'
      specialMode: 'no'

      nodeArray: []
      selectedArray: []

      currentNodeIndex: 0
      currentPageIndex: 0

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
      @setState
        mode: 'command'
        input: ':'
        cachedInput: @state.input
    else
      @setState
        mode: 'query'
        input: @state.cachedInput
        cachedInput: ''

  prevMode: ->
    if @state.mode is 'fast'
      @setState { mode: 'query' }
    else if @state.mode is 'command'
      @setState
        mode: 'fast'
        input: @state.cachedInput
        cachedInput: ''
    else
      @setState
        mode: 'command'
        input: ':'
        cachedInput: @state.input

  # ------------------------------------------------------------

  test: ->


# --------------------------------------------------------------
# --------------------------------------------------------------

QueryAction =
  open: ->
    Message.postMessage
      request: 'open'
      node: @getCurrentNode()
      option:
        active: yes

    @callAction('hide')

  openInBackground: ->
    Message.postMessage
      request: 'open'
      node: @getCurrentNode()
      option:
        active: no

  openInNewWindow: ->
    Message.postMessage
      request: 'openInNewWindow'
      node: @getCurrentNode()
      option:
        incognito: no

    @callAction('hide')

  openInNewIncognitoWindow: ->
    Message.postMessage
      request: 'openInNewWindow'
      node: @getCurrentNode()
      option:
        incognito: yes

    @callAction('hide')

# --------------------------------------------------------------
# --------------------------------------------------------------

FastAction =
  open: ->
    if _.isEmpty(@state.selectedArray)
      @callAction('q_open')
    else
      Message.postMessage
        request: 'open'
        nodeArray: _.at(@state.nodeArray, @state.selectedArray)
        option:
          active: yes
      @callAction('hide')

  openInBackground: ->
    if _.isEmpty(@state.selectedArray)
      @callAction('q_openInBackground')
    else
      Message.postMessage
        request: 'open'
        nodeArray: _.at(@state.nodeArray, @state.selectedArray)
        option:
          active: no

  openInNewWindow: ->
    if _.isEmpty(@state.selectedArray)
      @callAction('q_openInNewWindow')
    else
      Message.postMessage
        request: 'openInNewWindow'
        nodeArray: _.at(@state.nodeArray, @state.selectedArray)
        option:
          incognito: no

        @callAction('hide')

  openInNewIncognitoWindow: ->
    if _.isEmpty(@state.selectedArray)
      @callAction('q_openInNewIncognitoWindow')
    else
      Message.postMessage
        request: 'openInNewWindow'
        nodeArray: _.at(@state.nodeArray, @state.selectedArray)
        option:
          incognito: yes

        @callAction('hide')

  # ------------------------------------------------------------

  select: ->
    unless _.contains(@state.selectedArray, @getCurrentNodeIndex())
      selectedArray = _.union(@state.selectedArray, [@getCurrentNodeIndex()])
      @setState { selectedArray }

  unselect: ->
    if _.contains(@state.selectedArray, @getCurrentNodeIndex())
      selectedArray = _.without(@state.selectedArray, @getCurrentNodeIndex())
      @setState { selectedArray }

  # ------------------------------------------------------------

  tag: ->
    if _.isEmpty(@getCurrentNode().tagArray)
      input = ''
    else
      input = @getCurrentNode().tagArray.join(' ') + ' '

    @setState
      specialMode: 'tag'
      input: input


# --------------------------------------------------------------
# --------------------------------------------------------------

# Map command to command actions
CommandMap =
  '1'         : 'c_one'

  'tag'       : 'c_tag'

  'a'         : 'c_addBookmark'
  'add'       : 'c_addBookmark'

  's'         : 'c_storeTag'
  'sTag'      : 'c_storeTag'

# Command is entered and then executed
# If additional user-input is needed, enter specialMode
CommandAction =
  execute: ->
    if @state.input[0] isnt ':'
      return

    command = @state.input.split(' ')[0][1..]
    actionName = CommandMap[command]

    @callAction(actionName)

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

  addBookmark: ->
    @setState
      specialMode: 'addBookmark'
      input: ''

    Listener.setListener 'a_queryTab', (message) =>
      console.log 'here'
      tab = message.tabArray[0]
      node =
        title: tab.title
        # This property is specifically added for this operation
        # Doesn't exist in normal nodes
        url: tab.url

      @setState
        nodeArray: [node]

      Listener.removeListener('a_queryTab')

    Message.postMessage
      request: 'queryTab'
      queryInfo:
        active: yes
        currentWindow: yes

  storeTag: ->
    Message.postMessage
      request: 'storeTag'

# --------------------------------------------------------------
# --------------------------------------------------------------

SpecialAction =
  confirm: ->
    @callAction('s_' + @state.specialMode)
    @setState { input: '' }
    @setState { specialMode: 'no' }

  abort: ->
    @setState { specialMode: 'no' }

  # ------------------------------------------------------------

  tag: ->
    tokenArray = @state.input.split(' ')
    tagArray = _.filter tokenArray, (token) ->
      token[0] is '#' or token[0] is '@'

    Message.postMessage
      request: 'addTag'
      node: @getCurrentNode()
      tagArray: tagArray

  addBookmark: ->
    node = @state.nodeArray[0]
    Message.postMessage
      request: 'addBookmark'
      bookmark:
        title: node.title
        url: node.url
      tagArray: node.tagArray




