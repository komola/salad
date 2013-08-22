module.exports =
  InstanceMethods:
    takeSnapshot: ->
      @previousValues = _.clone @getAttributes(), true

    getSnapshot: ->
      @previousValues or {}

    getChangedAttributes: ->
      changes = {}

      current = @getAttributes()
      previous = @getSnapshot()

      for key, newValue of current
        oldValue = previous[key]
        continue if _.isEqual newValue, oldValue

        changes[key] = [oldValue, newValue]

      changes
