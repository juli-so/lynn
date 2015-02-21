$ ->
  Message.init()
  Listener.init()

  # Init UI
  $mountPoint = $("<div id='lynn_container'>")
  $('body').prepend($mountPoint)

  React.render Lynn(), $mountPoint[0]
