# ---------------------------------------------------------------------------- #
#                                                                              #
# Main process                                                                 #
#                                                                              #
# ---------------------------------------------------------------------------- #

WinTab.init()
Session.init()
Message.init()
Tag.init()

CStorage.init ->
  Bookmark.init()
  #Sync.init()
