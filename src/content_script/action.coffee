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
      mode: 'query'

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
      mode = 'fast'
    else if @state.mode is 'fast'
      mode = 'command'
    else
      mode = 'query'

    @setState { mode }
    
  prevMode: ->
    if @state.mode is 'fast'
      mode = 'query'
    else if @state.mode is 'command'
      mode = 'fast'
    else
      mode = 'command'

    @setState { mode }

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
    @setState
      specialMode: 'tag'
      input: ''


# --------------------------------------------------------------
# --------------------------------------------------------------

CommandAction =
  execute: ->
    tokenArray = @state.input.split(' ')
    # example or custom shortcuts
    if tokenArray[0] is ':1'
      Message.postMessage
        request: 'open'
        nodeArray: [
          { url: 'http://www.google.com' },
          { url: 'http://lodash.com/docs' }
        ]
        option:
          active: no
      @callAction('hide')

# --------------------------------------------------------------
# --------------------------------------------------------------

SpecialAction =
  confirm: ->
    @callAction('s_' + @state.specialMode)
    @setState { input: '' }
    @setState { specialMode: 'no' }

  abort: ->
    @callAction('reset')
    @setState { specialMode: 'no' }

  tag: ->
    tokenArray = @state.input.split(' ')
    tagArray = _.filter tokenArray, (token) ->
      token[0] is '#' or token[0] is '@'

    Message.postMessage
      request: 'addTag'
      node: @getCurrentNode()
      tagArray: tagArray


