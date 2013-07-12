module.exports =
  ClassMethods:
    pagination: ->
      _json = @::json

      @include
        _index: (callback) ->
          @applyPaginationDefaults()

          @scoped (err, scope) =>
            scope = scope.limit(@params.limit).offset(@params.offset)
            scope.findAndCountAll (err, result) =>
              @paginationTotal = result.count

              callback.apply @, [err, result.rows]

        json: (data) ->
          if @params.action is "index"
            data = @_buildPaginationResult data

          _json.call @, data

  InstanceMethods:
    _buildPaginationResult: (data) ->
      totalPages = Math.ceil(@paginationTotal / @params.limit)
      currentPage = Math.ceil(@params.offset / @params.limit)

      response =
        total: @paginationTotal
        page: currentPage
        totalPages: totalPages
        limit: @params.limit
        offset: @params.offset
        items: data

      response

    applyPaginationDefaults: ->
      @params.limit or= 20
      @params.limit = parseInt @params.limit, 10

      if @params.limit < 1
        @params.limit = 20

      @params.offset or= 0
      @params.offset = parseInt @params.offset, 10
      if @params.offset < 1
        @params.offset = 0
