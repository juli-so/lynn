$(->
  Message.init()

  # Init UI
  $('body').prepend("<div id='react'>")
  React.renderComponent Accessor(), $('#react')[0]

)
