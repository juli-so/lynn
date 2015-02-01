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

$(->
  initMenuAnimation()

  chrome.storage.local.get ['option', 'state'], (storObj) ->
    React.renderComponent(Dashboard(storObj), $('#dashboard_container')[0])
)
