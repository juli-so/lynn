Shortcut =
  init: ->
    $(document).keyup (event) ->
      # Top level shortcut
      if event.ctrlKey and event.keyCode == 66
        $('#m_accessor').toggle()
        $('#m_command_input').focus()

      # Shortcut within command input focus
      
