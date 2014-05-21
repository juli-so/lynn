$(->
  Message.init()

  $('body').prepend("<div id='react'>")

  React.renderComponent Accessor(), $('#react')[0]
)
