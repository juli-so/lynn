{ div, span, a, b, p, ol, ul, li } = React.DOM
{ h1, h2, h3, h4, h5, h6 }         = React.DOM
{ hr }                             = React.DOM

DashboardClass = React.createClass
  render: ->
    div id: 'dashboard_content',
      div null,

        h2 null, 'Bookmark Stats'

        if @props.stats.bmAmount is 0
          div null, 'No bookmark yet'
        else
          p null, "Total bookmark count: #{@props.stats.bmAmount}"
          p null, "#{@props.stats.tagBmAmount} tagged,
                   around #{@props.stats.tagPercent}%"
          p null, "#{@props.stats.noTagBmAmount} not tagged, 
                   around #{@props.stats.noTagPercent}%"

          div className: 'five-rand',
            span className: 'five-rand-hint', 'Five random bookmarks to explore: '
            ul null,
              _.map @props.stats.fiveRandBm, (bm) ->
                li key: bm.url + bm.id,
                  a href: bm.url, bm.title

      div null,
        h2 null, 'Auto-tagging'

        if _.isEmpty(@props.state.autoTaggingMap)
          div null, 'No auto-tagging rule'
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
              li key: tagName, autoTagDescription,
                span className: 'lynn_tag', tagName

      div null,
        h2 null, 'Sessions'

        if _.isEmpty(@props.state.sessionMap)
          div null, 'No session'
        else
          _.map @props.state.sessionMap, (sessionRecord, sessionName) ->
            div key: sessionName,
              p null,
                b null, ":#{sessionName}"
                " to invoke"
              if sessionRecord.type is 'window'
                ul className: 'dash-list',
                  _.map sessionRecord.session, (node) ->
                    li { key: node.url + node.id },
                      a href: node.url, node.title
              else
                ul null,
                  _.map sessionRecord.session, (nodeArray) ->
                    ul
                      key: JSON.stringify(nodeArray)
                      className: 'dash-list',
                      hr {},
                      _.map nodeArray, (node) ->
                        li { key: node.url + node.id },
                          a href: node.url, node.title

Dashboard = React.createFactory(DashboardClass)
