# Options, will be made into options page later
MAX_SUGGESTION_NUM = 8

{ div, span, input } = React.DOM

# Suggestion

Mainline = React.createClass
  render: ->
    div {className: 'm_mainline'},
      span {className: 'm_title'},
        @props.title

Tagline = React.createClass
  render: ->
    div {className: 'm_tagline'},
      _.map @props.tagArray, (tag) ->
        if tag[0] == '@'
          span {className: 'm_tag'}, tag
        else
          span {className: 'm_tag'}, '#', tag

Suggestion = React.createClass
  render: ->
    className = 'm_suggestion animated fadeInLeft'
    className += ' m_suggestion_current' if @props.isCurrent
    div {className},
      Mainline {title: @props.title}
      Tagline {tagArray: @props.tagArray}

Notification = React.createClass
  render: ->
    numToString = ['Zero', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten']

    div {className: 'm_notification'},
      'Page ' + numToString[@props.page]

# Accessor
Accessor = React.createClass
  # 
  # Life cycle
  #
  getInitialState: ->
    query: ''
    nodeArray: []
    maxSuggestionNum: MAX_SUGGESTION_NUM
    currentNodeIndex: 0
    currentPage: 1

    accessorVisible: false

  componentWillMount: ->
    # Listen to response to the message sent in @handleChange
    Message.addListener (message) =>
      if message.response == 'search'
        @setState {nodeArray: message.result}

    # Hijack global shortcuts
    $(document).keydown (event) =>
      # Toggle command input
      if event.ctrlKey and event.keyCode == 66
        @toggle()

      # Shortcut invoked when command input has focus
      if $('#m_command_input').is(':focus')
        @onKeyDown(event)

  componentDidUpdate: (prevProps, prevStates) ->
    if @state.accessorVisible
      $('#m_accessor').show()
      $('#m_command_input').focus()
    else
      $('#m_accessor').hide()

  render: ->
    inputProps =
      id:'m_command_input'
      type: 'text'
      size: '80'
      placeholder: 'Search for...'
      value: @state.query
      onChange: @handleChange

    start = (@state.currentPage - 1) * MAX_SUGGESTION_NUM
    end = Math.min(@state.nodeArray.length, start + MAX_SUGGESTION_NUM)

    div {id: 'm_accessor'},
      input inputProps

      div {id: 'm_suggestion_box'},
        _.map @state.nodeArray[start...end], (node, index) =>
          if index == @state.currentNodeIndex
            Suggestion {title: node.title, tagArray: node.tagArray, \
              key: node.id, isCurrent: true}
          else
            Suggestion {title: node.title, tagArray: node.tagArray, \
              key: node.id, isCurrent: false}

      Notification {page: @state.currentPage}

  #
  # Helper
  #
  toggle: ->
    @setState {accessorVisible: not @state.accessorVisible}

  up: ->
    currentNodeIndex = (@state.currentNodeIndex + @state.maxSuggestionNum - 1) \
      % @state.maxSuggestionNum
    @setState {currentNodeIndex}

  down: ->
    currentNodeIndex = (@state.currentNodeIndex + 1) % @state.maxSuggestionNum
    @setState {currentNodeIndex}

  pageUp: ->
    if @state.currentPage > 1
      @setState {currentPage: @state.currentPage - 1, currentNodeIndex: 0}

  pageDown: ->
    if @state.currentPage * MAX_SUGGESTION_NUM < @state.nodeArray.length
      @setState {currentPage: @state.currentPage + 1, currentNodeIndex: 0}

  reset: ->
    @setState {query: '', nodeArray: [], currentNodeIndex: 0}

  handleChange: (event) ->
    query = event.target.value
    if _.isEmpty(query)
      @reset()
    else
      @setState {query}

      Message.postMessage {request: 'search', command: query}

  onKeyDown: (event) ->
    if event.shiftKey and event.keyCode == 13
      node = @state.nodeArray[@state.currentNodeIndex]
      Message.postMessage({request: 'openInNewWindow', node})
    if not event.shiftKey and event.keyCode == 13
      node = @state.nodeArray[@state.currentNodeIndex]
      Message.postMessage({request: 'open', node})
    # Esc key is hijacked by vimium now, I'll hijack it back later
    # if event.keyCode == 27
    # @reset()
    if event.ctrlKey and event.keyCode == 8
      @reset()
    if event.keyCode == 38
      @up()
    if event.keyCode == 40
      @down()
    if event.keyCode == 33
      @pageUp()
    if event.keyCode == 34
      @pageDown()
    # Test command C-M
    if event.ctrlKey and event.keyCode == 77
      Message.postMessage
        request: 'addTag'
        node: @state.nodeArray[@state.currentNodeIndex]
        tag: @state.query

