{ div, span, a, b, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }         = React.DOM
{ hr }                             = React.DOM

Tagging = React.createClass
  render: ->
    div null,
      h2 null, 'Auto-tagging',

        h3 null, 'Current rules'
          if _.isEmpty(@props.state.autoTaggingMap)
            'No auto-tagging rule'
          else
            ul null,
              _.map @props.state.autoTaggingMap, (autoTagRecord, tagName) ->
                if autoTagRecord.matchProp is 'hostname'
                  if autoTagRecord.matchType is 'exact'
                    prereq = 'If hostname is exactly ' + autoTagRecord.matchStr
                  else
                    prereq = 'If hostname contains ' + autoTagRecord.matchStr
                else
                  prereq = 'If bookmark title contains ' + autoTagRecord.matchStr

                autoTagDescription = prereq + ' -> '
                li null, autoTagDescription,
                  span { className: 'lynn_tag' }, tagName

        div { className: 'custom-hr' }

        h3 null, 'Add a rule'
        p null, 'Tag name'
        input {
          type: 'text'
          id: 'autoTagging_tag'
          placeholder: 'Your tag here'
        }

        hr

        p null, 'Match property'
        input {
          type: 'text'
          id: 'autoTagging_matchProp'
          placeholder: 'hostname or title?'
        }

        hr

        p null, 'Match type'
        input {
          type: 'text'
          id: 'autoTagging_matchType'
          placeholder: 'contains or exact?'
        }

        hr

        p null, 'Match string'
        input {
          type: 'text'
          id: 'autoTagging_matchStr'
          placeholder: 'The string to match against'
        }

        div { className: 'controls' },
          span { id: 'add-autotagging-rule-result', className: 'result transparent' }, 'Success'
          div { className: 'spacer' }
          button
            id: 'autotagging-example'
            onClick: @props.autoTaggingExample
          , 'Example'
          button
            id: 'add-autotagging-rule'
            onClick: @props.addAutoTaggingRule
          , 'Add rule'

        h3 null, 'Remove a rule'
        p null, 'Tag name'
        input {
          type: 'text'
          id: 'autoTagging_remove_tag'
          placeholder: 'Your tag here'
        }

        div { className: 'controls' },
          span { id: 'remove-autotagging-rule-result', className: 'result transparent' }, 'Success'
          div { className: 'spacer' }
          button
            id: 'remove-autotagging-rule'
            onClick: @props.removeAutoTaggingRule
          , 'Remove'

