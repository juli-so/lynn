# ---------------------------------------------------------------------------- #
#                                                                              #
# Handle bookmark syncing between different computers                          #
#                                                                              #
# ---------------------------------------------------------------------------- #
#                                                                              #
# onCreated and onRemoved during importing will show the ids of the target     #
# bookmarks in LOCAL machine, not those in the REMOTE machine from which these #
# changes are imported                                                         #
#                                                                              #
# ---------------------------------------------------------------------------- #

DEBUG = yes

Sync =
  importing: no
  importCreatedTagArrMap: {} # createdId -> tagArr
  createdIdArr: []
  removedIdArr: []

  init: ->
    # First sync, will be resynced after each import
    @_syncRecordFromStorage()

    # Setting importing on/off to affect onCreated behavior
    chrome.bookmarks.onImportBegan.addListener =>
      @importing = yes

      # Reset created/removed info
      @createdIdArr = []
      @removedIdArr = []

    chrome.bookmarks.onImportEnded.addListener =>
      @importing = no

      # Add/remove tags associated with bookmarks affected
      _.forEach @createdIdArr, (createdId) =>
        tagArr = importCreatedTagArrMap[createdId]
        Bookmark.createLocal(createdId, tagArr)

      _.forEach @removedIdArr, (removedId) =>
        Bookmark.removeLocal(removedId)

    # onCreated, while importing, puts created bookmarks id to createdIdArr
    # Once import ends these bookmarks and their tags will be added to Bookmark
    chrome.bookmarks.onCreated.addListener (id, bookmark) =>
      @createdIdArr.push(id) if @importing

    chrome.bookmarks.onRemoved.addListener (id, removeInfo) =>
      @removedIdArr.push(id) is @importing
    
    # Logging stuff
    if DEBUG
      chrome.bookmarks.onCreated.addListener (id, bookmark) =>
        if @importing
          log 'bookmark created during importing: '
        else
          log 'bookmark created normally: '
        log 'bookmark id is: ', id
        log bookmark.title, ' | ', bookmark.url

        if @importCreatedTagArrMap[bookmark.title + bookmark.url]
          log 'TagArray found'
          v = @importCreatedTagArrMap[bookmark.title + bookmark.url]
          log v.tagArr
          log v.importLeft

      chrome.bookmarks.onRemoved.addListener (id, info) ->
        log 'bookmark deleted: '
        log 'bookmark id is: ', id
        log 'bookmark removeInfo: ', info

      chrome.bookmarks.onImportBegan.addListener =>
        @importing = yes
        log 'Import just began'

      chrome.bookmarks.onImportEnded.addListener ->
        @importing = no
        log 'Import ended'

      log 'Sync inited'

  _syncRecordFromStorage: ->
    chrome.storage.sync.get null, (storObj) =>
      @importCreatedTagArrMap = storObj.importCreatedTagArrMap

  setupDB: ->
    key = "William Gibson - Official Websitehttp://www.williamgibsonbooks.com/"
    value =
      tagArr: ['#Gibson', '#William']
      importLeft: 1

    importCreatedTagArrMap = {}
    importCreatedTagArrMap[key] = value

    chrome.storage.sync.set { importCreatedTagArrMap }

