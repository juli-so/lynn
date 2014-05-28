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
        span {className: 'm_tag'}, '#', tag

Suggestion = React.createClass
  render: ->
    className = 'm_suggestion'
    className += ' m_suggestion_current' if @props.isCurrent
    div {className},
      Mainline {title: @props.title}
      Tagline {tagArray: @props.tagArray}

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

    accessorVisible: false

  componentWillMount: ->
    # Listen to response to the message sent in @handleChange
    Message.addListener (message) =>
      if message.response == 'search'
        @setState {nodeArray: message.result}

    # Hijack global shortcuts
    $(document).keyup (event) =>
      # Toggle command input
      if event.ctrlKey and event.keyCode == 66
        @toggle()

      # Shortcut invoked when command input has focus
      if $('#m_command_input').is(':focus')
        @onKeyUp(event)

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
      onChange: @handleChange

    div {id: 'm_accessor'},
      input inputProps

      div {id: 'm_suggestion_box'},
        _.map @state.nodeArray[0...MAX_SUGGESTION_NUM], (node, index) =>
          if index == @state.currentNodeIndex
            Suggestion {title: node.title, tagArray: node.tagArray, \
              key: node.id, isCurrent: true}
          else
            Suggestion {title: node.title, tagArray: node.tagArray, \
              key: node.id, isCurrent: false}

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

  reset: ->
    @setState {query: '', nodeArray: [], currentNodeIndex: 0}

  handleChange: (event) ->
    query = event.target.value
    if _.isEmpty(query)
      @reset()
    else
      @setState {query}

      Message.postMessage {request: 'search', command: query}

  onKeyUp: (event) ->
    if event.keyCode == 13
      url = @state.nodeArray[@state.currentNodeIndex].url
      Message.postMessage({request: 'open', url})
    # Esc key is hijacked now, I'll hijack it back later
    # if event.keyCode == 27
    if event.ctrlKey and event.keyCode == 8
      @reset()
    if event.keyCode == 38
      @up()
    if event.keyCode == 40
      @down()

