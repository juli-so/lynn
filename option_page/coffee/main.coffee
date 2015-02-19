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

# ---------------------------------------------------------------------------- #
# Go                                                                           #
# ---------------------------------------------------------------------------- #

$ ->
  initMenuAnimation()

  Message.init()
  Listener.init()

  render()

  $('.menu a[href=#general]').click()
