# ---------------------------------------------------------------------------- #
#                                                                              #
# Some functions exposed for testing                                           #
#                                                                              #
# ---------------------------------------------------------------------------- #

T =
  # ------------------------------------------------------------
  # Helper
  # ------------------------------------------------------------

  # Sync storage
  pst: (prop) ->
    if prop
      chrome.storage.sync.get null, (o) -> log(o[prop])
    else
      chrome.storage.sync.get(null, log)

  sst: (prop, value) ->
    obj = {}
    obj[prop] = value
    chrome.storage.sync.set(obj)

  rst: (prop) ->
    chrome.storage.sync.remove(prop)

  # Local storage
  plt: (prop) ->
    if prop
      chrome.storage.local.get null, (o) -> log(o[prop])
    else
      chrome.storage.local.get(null, log)

  pbm: (id) ->
    chrome.bookmarks.get(id + '', (o) -> log(o[0]))

  # ------------------------------------------------------------
  # Go
  # ------------------------------------------------------------

  go: ->
    Bookmark.addTag(7, '#ha')
    Bookmark.addTag(7, '#lo')
    Bookmark.addTag(8, '#ha')
    Bookmark.addTag(10, '#yo')
    Bookmark.addTag(10, '#hoo')
    Bookmark.addTag(15, '@hoo')
    Bookmark.addTag(15, '#hey')
