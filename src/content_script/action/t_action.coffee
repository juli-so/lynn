# ---------------------------------------------------------------------------- #
#                                                                              #
# Site-specific actions, prefix is 't_'                                        #
#                                                                              #
# ---------------------------------------------------------------------------- #

T_Action =
  addHNBookmark: (args) ->
    if not args
      @callAction('i_h_addSelection', ['td.title > a'])
    else
      docFrag = document.querySelector('tbody')
      # Here args is the indexes of all entries the user want to bookmark
      indexArr = _.map(args, (x) -> x - 2)
      linkArr = _.at(docFrag.querySelectorAll('td.title > a'), indexArr)

      nodeArr = _.map linkArr, (link) ->
        title: link.text
        url: link.href
        tagArr: []
        suggestedTagArr: []

      @setState
        input: ''
        specialMode: 'addSelectionBookmark'
        nodeArr: nodeArr
        selectedArr: [0...nodeArr.length]

  postHN: ->
    Listener.listenOnce 'queryTab', {}, (message) =>
      node = Util.tabToNode(message.current)

      url = "http://news.ycombinator.com/submitlink?u=#{node.url}&t=#{node.title}"
      
      console.log url
      Message.postMessage
        req: 'open'
        option:
          active: yes
        node:
          url: url

      @callAction('n_hide')
