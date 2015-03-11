{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }      = React.DOM
{ textarea }                    = React.DOM
{ input, button }               = React.DOM

JsonIO = React.createClass
  render: ->
    div null,
      textarea { id: 'jsonio', rows: 20, cols: 56 },
      JSON.stringify(@props.allNode, null, 2)

      div { className: "top-hr" },
        button { id: 'json-select' }, "Select All"




