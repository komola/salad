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
          if @params.action isnt "index"
            return _json.call @, data

          totalPages = Math.ceil(@paginationTotal / @params.limit)
          currentPage = Math.ceil(@params.offset / @params.limit)

          response =
            total: @paginationTotal
            page: currentPage
            totalPages: totalPages
            limit: @params.limit
            offset: @params.offset
            items: data

          _json.call @, response

  InstanceMethods:
    applyPaginationDefaults: ->
      @params.limit or= 20

      if @params.limit < 1
        @params.limit = 20

      @params.offset or= 0
