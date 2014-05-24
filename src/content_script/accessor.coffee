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
    div {className: 'm_suggestion'},
      Mainline {title: @props.title}
      Tagline {tagArray: @props.tagArray}

# Accessor
Accessor = React.createClass
  getInitialState: ->
    query: ''
    nodeArray: []

    accessorVisible: false

  componentWillMount: ->
    # Listen to response to the message sent in @handleChange
    Message.addListener (msg) =>
      @setState {nodeArray: msg.result}

    # Hijack global shortcuts
    $(document).keyup (event) =>
      # Invoking command input
      if event.ctrlKey and event.keyCode == 66
        @toggle()

  toggle: ->
    @setState {accessorVisible: not @state.accessorVisible}

  componentDidUpdate: (prevProps, prevStates) ->
    if @state.accessorVisible
      $('#m_accessor').show()
      $('#m_command_input').focus()
    else
      $('#m_accessor').hide()
      $('#m_command_input').focus()

  handleChange: (event) ->
    query = event.target.value
    @setState {query}

    Message.postMessage {request: 'search', command: query}

  onKeyUp: (event) ->
    if event.keyCode == 13
      Message.postMessage({request: 'open', url: @state.nodeArray[0].url})
    if event.keyCode == 27
      @reset()

  render: ->
    inputProps =
      id:'m_command_input'
      type: 'text'
      size: '80'
      placeholder: 'Search for...'
      onChange: @handleChange

    div {id: 'm_accessor', onKeyUp: @onKeyUp},
      input inputProps

      div {id: 'm_suggestion_box'},
        _.map @state.nodeArray, (node) ->
          Suggestion {title: node.title, tagArray: node.tagArray, key: node.id}

  reset: ->
    $('#m_command_input').val('')
    @setState {query: '', nodeArray: []}
