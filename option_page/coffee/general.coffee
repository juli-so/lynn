{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }      = React.DOM
{ hr }                          = React.DOM
{ input, button }               = React.DOM

General = React.createClass
  render: ->
    div {},
      p {}, "Command to Open / Hide Lynn"
      p {}, "Only b / m / y / i supported now"
      p {}, "Default is b"
      span {}, "Ctrl + "
      input {
        type: "text"
        id: "MAIN_SHORTCUT"
        defaultValue: @props.option['MAIN_SHORTCUT']
      }

      div { className: "custom-hr" }

      p {}, "Number of suggestion shown"
      p {}, "Default is 8"

      span {}, "Show "
      input {
        type: "text"
        id: "MAX_SUGGESTION_NUM"
        defaultValue: @props.option['MAX_SUGGESTION_NUM']
      }
      span {}, " every page"

      div { className: "custom-hr" }

      p {}, "How many removed bookmarks saved for recovering later"
      p {}, "Default is 10"

      span {}, "Store "
      input {
        type: "text"
        id: "MAX_RECOVER_NUM"
        defaultValue: @props.option['MAX_RECOVER_NUM']
      }
      span {}, " bookmarks for recovering later"

      div { className: "save-top-border" },
        button { id: "save-general", onClick: @props.save }, "Save"
