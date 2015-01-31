save = ->
  MAX_SUGGESTION_NUM = parseInt($('#MAX_SUGGESTION_NUM').val(), 10)

  option =
    MAX_SUGGESTION_NUM: MAX_SUGGESTION_NUM

  if isValid(option)
    chrome.storage.sync.get 'option', (storObj) ->
      option = _.assign(storObj.option || {}, option)
      chrome.storage.sync.set { option }

isValid = (option) ->
  { MAX_SUGGESTION_NUM } = option
  isValid =
    MAX_SUGGESTION_NUM > 0

  return isValid

initTab = ->
  $('.menu a').click (ev) ->
    ev.preventDefault()

    $('.mainview > *').removeClass('selected')
    $('.menu li').removeClass('selected')
    setTimeout (-> $('.mainview > *:not(.selected)').css('display', 'none')), 100

    $(ev.currentTarget).parent().addClass('selected')
    currentView = $($(ev.currentTarget).attr('href'))
    currentView.css('display', 'block')
    setTimeout (-> currentView.addClass('selected')), 0

$(->
  # Initiation
  initTab()

  chrome.storage.sync.get null, (storObj) ->
    React.renderComponent Dashboard({ storObj }),
      $('#dashboard_container')[0]

    $('#MAX_SUGGESTION_NUM').val(storObj.option['MAX_SUGGESTION_NUM'])

  $('#save').click ->
    save()
)
