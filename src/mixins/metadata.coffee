module.exports =
  InstanceMethods:
    metadata: ->
      @__proto__.constructor._metadata or= {}


      @__proto__.constructor._metadata

  ClassMethods:
    metadata: ->
      @_metadata or= {}

      # make sure that we don't have references to the parents
      # metadata object. This would cause triggers and sorts to pile up in every
      # sub-class, leading to trigger actions that can't be found.
      if @_metadata is @__super__.constructor._metadata
        @_metadata = _.clone @__super__.constructor._metadata, true

      @_metadata