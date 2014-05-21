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

  componentWillMount: ->
    Message.addListener ((msg) ->
      @setState {nodeArray: msg.result}
    ).bind(@)

  handleChange: (event) ->
    query = event.target.value
    @setState {query}

    Message.postMessage {request: 'search', command: query}

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
        _.map @state.nodeArray, (node) ->
          Suggestion {title: node.title, tagArray: node.tagArray}


