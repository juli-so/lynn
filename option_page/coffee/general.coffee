{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }      = React.DOM
{ hr }                          = React.DOM
{ input, button }               = React.DOM

General = React.createClass
  render: ->
    div null,
      p null, 'Command to Open / Hide Lynn'
      p null, 'Only b / m / y / i supported now'
      p null, 'Default is b'
      span null, 'Ctrl + '
      input {
        type: 'text'
        id: 'MAIN_SHORTCUT'
        defaultValue: @props.option['MAIN_SHORTCUT']
      }

      div { className: 'custom-hr' }

      p null, 'Number of suggestion shown'
      p null, 'Default is 8'

      span null, 'Show '
      input {
        type: 'text'
        id: 'MAX_SUGGESTION_NUM'
        defaultValue: @props.option['MAX_SUGGESTION_NUM']
      }
      span null, ' every page'

      div { className: 'custom-hr' }

      div { className: 'bot-20px-margin' },
        p null, 'How many removed bookmarks saved for recovering later'
        p null, 'Default is 10'

        span null, 'Store '
        input {
          type: 'text'
          id: 'MAX_RECOVER_NUM'
          defaultValue: @props.option['MAX_RECOVER_NUM']
        }
        span null, ' bookmarks for recovering later'

      div { className: 'controls-top' },
        span { id: 'save-result', className: 'result transparent' }, 'Success'
        div { className: 'spacer' }
        button { id: 'save-general', onClick: @props.save }, 'Save'
