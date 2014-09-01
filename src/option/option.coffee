save = ->
  MAX_SUGGESTION_NUM = parseInt($('#MAX_SUGGESTION_NUM').val(), 10)

  chrome.storage.sync.get 'option', (storageObject) ->
    option = storageObject.option || {}
    option.MAX_SUGGESTION_NUM = MAX_SUGGESTION_NUM
    chrome.storage.sync.set { option }

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

  chrome.storage.sync.get null, (storageObject) ->
    React.renderComponent Dashboard({ storageObject }),
      $('#dashboard_container')[0]

    $('#MAX_SUGGESTION_NUM').val(storageObject.option['MAX_SUGGESTION_NUM'])
    console.log storageObject

  $('#save').click ->
    save()
)
