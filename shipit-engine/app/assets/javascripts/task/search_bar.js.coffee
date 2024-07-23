class @SearchBar
  DEBOUNCE = 300

  constructor: (@$bar) ->
    @eventListeners = {}
    @query = window.location.hash.replace(/^#/, '')
    @$input = @$bar.find('.search-input')
    @$input.on('blur', @closeIfEmpty)
    @$input.on('input', @updateQuery)
    @broadcastQueryChange = _.debounce(@immediateBroadcastQueryChange, DEBOUNCE)
    Mousetrap.bindGlobal(['command+f', 'ctrl+f'], @open)

    if @query
      @open()
      @setQuery(@query)

  addEventListener: (type, handler) ->
    @listeners(type).push(handler)

  listeners: (type) ->
    @eventListeners[type] ||= []

  setQuery: (query) ->
    @$input.val(query)
    @updateQuery()

  updateQuery: =>
    oldQuery = @query
    @query = @$input.val()
    @broadcastQueryChange() unless @query == oldQuery

  immediateBroadcastQueryChange: =>
    @updateHash()
    for handler in @listeners('query')
      handler(@query)

  updateHash: ->
    window.location.hash = "##{@query}"

  open: (event) =>
    event?.preventDefault()
    @$bar.removeClass('hidden')
    @focus()

  focus: ->
    @$input.focus()[0].select()

  closeIfEmpty: (event) =>
    @close() unless @query.length

  close: ->
    @$bar.addClass('hidden')
