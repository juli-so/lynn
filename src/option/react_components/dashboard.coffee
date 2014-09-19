{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 } = React.DOM

Dashboard = React.createClass
  render: ->
    div id: 'dashboard_content',
      h3 null, 'General info'
      div { style: { 'margin-bottom': '30px' }},
        p null, '* Bookmark amount: ', 256
        p null, '* Tag amount: ', 27

      h3 null, 'Custom Setting'

      div null,
        h4 null, 'Auto-tagging'
        ul null,
          _.map @props.storageObject.autoTaggingMap, (autoTagRecord, tagName) ->
            if autoTagRecord.matchProp is 'hostname'
              if autoTagRecord.matchType is 'exact'
                prereq = 'If hostname is exactly ' + autoTagRecord.matchString
              else
                prereq = 'If hostname contains ' + autoTagRecord.matchString
            else
              prereq = 'If bookmark title contains ' + autoTagRecord.matchString

            autoTagDescription = '- ' + prereq + ' -> ' + tagName
            li null, autoTagDescription

      div null,
        h4 null, 'Sessions'
        _.map @props.storageObject.sessionMap, (nodeArray, sessionName) ->
          div null, ':', sessionName, ' to invoke: ',
            ul null,
              _.map nodeArray, (node) ->
                li null, '- ',
                  a { href: node.url }, node.title

      div null,
        h4 null, 'Synotags'



