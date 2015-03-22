# ---------------------------------------------------------------------------- #
#                                                                              #
# Script for options page                                                      #
#                                                                              #
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# Helper                                                                       #
# ---------------------------------------------------------------------------- #

toggleSuccessFadeMsg = (id) ->
  $('#' + id).toggleClass('success-result')
  fade = -> $('#' + id).toggleClass('success-result')
  setTimeout(fade, 1300)

saveGeneral = ->
  MAIN_SHORTCUT = $('#MAIN_SHORTCUT').val()
  MAX_SUGGESTION_NUM = $('#MAX_SUGGESTION_NUM').val()
  MAX_RECOVER_NUM = $('#MAX_RECOVER_NUM').val()

  optionObj = { MAIN_SHORTCUT, MAX_SUGGESTION_NUM, MAX_RECOVER_NUM }
  CStorage.setOption optionObj, ->
    render()
    toggleSuccessFadeMsg('save-result')

addAutoTaggingRule = ->
  tag       = $('#autoTagging_tag'      ).val()
  matchProp = $('#autoTagging_matchProp').val()
  matchType = $('#autoTagging_matchType').val()
  matchStr  = $('#autoTagging_matchStr' ).val()

  reqObj = { tag, matchProp, matchType, matchStr }
  return if _.any(reqObj, _.isEmpty)

  Listener.listenOnce 'addAutoTaggingRule', reqObj, ->
    render()
    toggleSuccessFadeMsg('add-autotagging-rule-result')

removeAutoTaggingRule = ->
  tag = $('#autoTagging_remove_tag').val()
  return if _.isEmpty(tag)

  Listener.listenOnce 'removeAutoTaggingRule', { tag }, ->
    render()
    toggleSuccessFadeMsg('remove-autotagging-rule-result')

autoTaggingExample = ->
  $('#autoTagging_tag'      ).val('#python')
  $('#autoTagging_matchProp').val('title')
  $('#autoTagging_matchType').val('contains')
  $('#autoTagging_matchStr' ).val('python')

render = ->
  Listener.listenOnce 'stats', {}, (statsMsg) ->
    CStorage.getOption null, (option) ->
      CStorage.getState null, (state) ->
        React.render(
          Dashboard(
            option: option
            state:  state
            stats:  statsMsg.stats
          ), $('#dashboard_container')[0])

        React.render(
          General(
            option: option
            state:  state
            stats:  statsMsg.stats
            save:   saveGeneral
          ), $('#general_container')[0])

        React.render(
          Tagging(
            option: option
            state:  state
            autoTaggingExample: autoTaggingExample
            addAutoTaggingRule: addAutoTaggingRule
            removeAutoTaggingRule: removeAutoTaggingRule
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

