$(->
  Message.init()

  # Init UI
  $mountPoint = $("<div id='lynn'>")
  $('body').prepend($mountPoint)
  React.renderComponent Lynn(), $mountPoint[0]

)
