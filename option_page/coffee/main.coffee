# ---------------------------------------------------------------------------- #
#                                                                              #
# Script for options page                                                      #
#                                                                              #
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# Helper                                                                       #
# ---------------------------------------------------------------------------- #

saveGeneral = ->
  MAIN_SHORTCUT = $('#MAIN_SHORTCUT').val()
  MAX_SUGGESTION_NUM = $('#MAX_SUGGESTION_NUM').val()
  MAX_RECOVER_NUM = $('#MAX_RECOVER_NUM').val()

  optionObj = { MAIN_SHORTCUT, MAX_SUGGESTION_NUM, MAX_RECOVER_NUM }
  Listener.listenOnce 'setOption', { optionObj }, ->
    render()

addAutoTaggingRule = ->
  tag       = $('#autoTagging_tag'      ).val()
  matchProp = $('#autoTagging_matchProp').val()
  matchType = $('#autoTagging_matchType').val()
  matchStr  = $('#autoTagging_matchStr' ).val()

  reqObj = { tag, matchProp, matchType, matchStr }
  Listener.listenOnce 'addAutoTaggingRule', reqObj, ->
    render()

autoTaggingExample = ->
  $('#autoTagging_tag'      ).val('#python')
  $('#autoTagging_matchProp').val('title')
  $('#autoTagging_matchType').val('contains')
  $('#autoTagging_matchStr' ).val('python')

render = ->
  Listener.listenOnce 'stats', {}, (statsMsg) ->
    Listener.listenOnce 'getOption', {}, (optionMsg) ->
      Listener.listenOnce 'getState', {}, (stateMsg) ->
        React.render(
          Dashboard(
            option: optionMsg.option
            state:  stateMsg.state
            stats:  statsMsg.stats
          ), $('#dashboard_container')[0])

        React.render(
          General(
            option: optionMsg.option
            state:  stateMsg.state
            stats:  statsMsg.stats
            save:   saveGeneral
          ), $('#general_container')[0])

        React.render(
          Tagging(
            option: optionMsg.option
            state:  stateMsg.state
            addAutoTaggingRule: addAutoTaggingRule
            autoTaggingExample: autoTaggingExample
          ), $('#tagging_container')[0])

        React.render(JsonIO(
          allNode: statsMsg.stats.allNode
        ), $('#json_container')[0])

        initMenuAnimation()
        initJSONSelect()

# ---------------------------------------------------------------------------- #
# Init                                                                         #
# ---------------------------------------------------------------------------- #

# Init menu callback so animation will play when menu items get clicked
# Adapted from https://github.com/better-history/chrome-bootstrap
initMenuAnimation = ->
  $('.menu a').click (ev) ->
    ev.preventDefault()

    $('.selected').removeClass('selected')

    $(ev.currentTarget).parent().addClass('selected')
    currentView = $($(ev.currentTarget).attr('href'))
    currentView.show()
    currentView.addClass('selected')

initJSONSelect = ->
  $('#json-select').click (ev) ->
    ev.preventDefault()

    $('#jsonio').select()

# ---------------------------------------------------------------------------- #
# Go                                                                           #
# ---------------------------------------------------------------------------- #

$ ->
  Message.init()
  Listener.init()

  render()

