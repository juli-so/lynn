save = ->
  MAX_SUGGESTION_NUM = $('#MAX_SUGGESTION_NUM').val()
  console.log MAX_SUGGESTION_NUM
  chrome.storage.sync.set {MAX_SUGGESTION_NUM}

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

  chrome.storage.sync.get 'MAX_SUGGESTION_NUM', (storageObject) ->
    $('#MAX_SUGGESTION_NUM').val(storageObject['MAX_SUGGESTION_NUM'])

  $('#save').click ->
    save()
)
