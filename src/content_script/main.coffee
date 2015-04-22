# Global debug switch
DEBUG = no

$ ->
  Message.init()
  Listener.init()

  # Init UI
  $mountPoint = $("<div id='lynn_container'>")
  $('body').prepend($mountPoint)

  React.render(React.createElement(Lynn), $mountPoint[0])
