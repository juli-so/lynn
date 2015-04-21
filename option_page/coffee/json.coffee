{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }      = React.DOM
{ textarea }                    = React.DOM
{ input, button }               = React.DOM

JsonIOClass = React.createClass
  render: ->
    div null,
      textarea
        id: 'jsonio'
        rows: 20
        cols: 56
        value: JSON.stringify(@props.allNode, null, 2)
        readOnly: yes

      div { className: 'custom-hr'}
      div { className: 'right' },
        button { id: 'json-select' }, "Select All"

JsonIO = React.createFactory(JsonIOClass)
