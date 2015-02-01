{ div, span, a, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }      = React.DOM

Dashboard = React.createClass
  render: ->
    console.log @props

    div id: 'dashboard_content',
      div null,
        h2 null, 'Bookmark Stats'

        p null, "Total bookmark count: #{@props.stats.bmAmount}"
        p null, "#{@props.stats.tagBmAmount} tagged,
                 around #{@props.stats.tagPercent}%"
        p null, "#{@props.stats.noTagBmAmount} not tagged, 
                 around #{@props.stats.noTagPercent}%"

        div className: 'five-rand',
          span className: 'five-rand-hint', 'Five random bookmarks to explore: '
          ul null,
            _.map @props.stats.fiveRandBm, (bm) ->
              li null,
                a href: bm.url, bm.title


      div null,
        h2 null, 'Auto-tagging'
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
              p null, tagName

      div null,
        h2 null, 'Sessions'
        _.map @props.state.sessionMap, (sessionRecord, sessionName) ->
          div null, ':', sessionName, ' to invoke: ',
            if sessionRecord.type is 'window'
              ul className: 'dash-list',
                _.map sessionRecord.session, (node) ->
                  li null,
                    a href: node.url, node.title
            else
              ul null,
                _.map sessionRecord.session, (nodeArray) ->
                  ul className: 'dash-list',
                    _.map nodeArray, (node) ->
                      li null,
                        a href: node.url, node.title
