# ---------------------------------------------------------------------------- #
#                                                                              #
# Small Components of tag, bookmark suggestion, etc                            #
# Used by block.coffee                                                         #
#                                                                              #
# ---------------------------------------------------------------------------- #

{ div, span } = React.DOM

Tag = React.createClass
  render: ->
    className = switch @props.type
      when 'normal'   then 'lynn_tag'
      when 'suggest'  then 'lynn_suggested_tag'
      when 'pending'  then 'lynn_pending_tag'
      when 'special'  then 'lynn_special_tag'

    span { className }, @props.tag

Suggestion = React.createClass
  render: ->
    className = 'lynn_suggestion lynn-animated '
    className += @props.animation
    className += ' lynn_suggestion_current' if @props.isCurrent
    className += ' lynn_suggestion_selected' if @props.isSelected

    div { className },
      div className: 'lynn_mainline',
        span className: 'lynn_title',
          @props.node.title
      div className: 'lynn_tagline',
        if @props.useSuggestedTag
          _.map @props.node.suggestedTagArr, (tag) ->
            Tag { type: 'suggest', tag: tag }

        _.map @props.node.tagArr, (tag) ->
          if _.ciEquals(tag, '#todo')
            type = 'special'
          else
            type = 'normal'
          Tag { type, tag }

        _.map @props.node.pendingTagArr, (tag) ->
          Tag { type: 'pending', tag: tag }


