save = ->
  MAX_SUGGESTION_NUM = parseInt($('#MAX_SUGGESTION_NUM').val(), 10)

  chrome.storage.sync.get 'option', (storageObject) ->
    option = storageObject.option || {}
    option.MAX_SUGGESTION_NUM = MAX_SUGGESTION_NUM
    chrome.storage.sync.set { option }

$(->
  # UI Tab
  $('.menu a').click (ev) ->
    ev.preventDefault()

    $('.mainview > *').removeClass('selected')
    $('.menu li').removeClass('selected')
    setTimeout (-> $('.mainview > *:not(.selected)').css('display', 'none')), 100

    $(ev.currentTarget).parent().addClass('selected')
    currentView = $($(ev.currentTarget).attr('href'))
    currentView.css('display', 'block')
    setTimeout (-> currentView.addClass('selected')), 0

  chrome.storage.sync.get 'option', (storageObject) ->
    $('#MAX_SUGGESTION_NUM').val(storageObject.option['MAX_SUGGESTION_NUM'])

  $('#save').click ->
    save()
)
