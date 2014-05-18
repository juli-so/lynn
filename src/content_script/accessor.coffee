##############################################################################
# 
# Bookmark Accessor
#
##############################################################################

$(->
  Command.init()
  Accessor_ui.init()
  $('body').append(Accessor_ui.m_accessor)

  count = 0
  Accessor_ui.m_command_input.on('input', ->
    command = $(@).val()

    Command.addListener((message) ->
        Accessor_ui.renderSuggestion(message.result)
    )

    Command.postMessage(Command.request(command))
  )

  port = chrome.runtime.connect({ name: 'm_action' })
  $(document).keyup((event) ->
    if Accessor_ui.m_command_input.is(":focus")
      if event.keyCode == 13
        port.postMessage({ request: 'open', url: Accessor_ui.getCurrentNode().url })
    if event.keyCode == 66 and event.ctrlKey == true
      $('#m_accessor').toggle()
      $('#m_command_input').focus()
    # Up arrow
    if event.keyCode == 38
      Accessor_ui.prevSuggestion()
    # Down arrow
    if event.keyCode == 40
      Accessor_ui.nextSuggestion()
    # Esc
    if event.keyCode == 27
      Accessor_ui.clear()
  )
)

