class @Commit
  @decorate: (data) ->
    data.map (datum) -> new Commit(datum)

  constructor: (props) ->
    this[name] = value for name, value of props

  hasAuthor: (authorName) ->
    authorName and @authorName.indexOf(authorName) != -1
