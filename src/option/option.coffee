save = ->
  MAX_SUGGESTION_NUM = $('#MAX_SUGGESTION_NUM').val()
  chrome.storage.sync.set {MAX_SUGGESTION_NUM}, ->
    $('#status').text('Option saved')

$(->
  $('#save').click(save)
)

