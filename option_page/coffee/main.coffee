# ---------------------------------------------------------------------------- #
#                                                                              #
# Script for options page                                                      #
#                                                                              #
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

$ ->
  initMenuAnimation()

  Message.init()
  Listener.init()

  Listener.listenOnce 'stats', {}, (statsMsg) ->
    Listener.listenOnce 'getOption', {}, (optionMsg) ->
      Listener.listenOnce 'getState', {}, (stateMsg) ->
        React.renderComponent(
          Dashboard(
            option: optionMsg.option
            state:  stateMsg.state
            stats:  statsMsg.stats
          ), $('#dashboard_container')[0])
