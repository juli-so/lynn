# ---------------------------------------------------------------------------- #
#                                                                              #
# Some functions exposed for testing                                           #
#                                                                              #
# ---------------------------------------------------------------------------- #

T =
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
