# Salad Changelog

## Version 0.5.1
* Fix bug in count that was caused when an order statement was included in the 
  options

## Version 0.5.0
* Update to latest sequelize version

  You might have to add through: null to some of the sequelize associations.
  Since this might break some installations, this is marked as Version 0.5.0

## Version 0.4.2
* Remove the domains for requests that handled uncaught exceptions

## Version 0.4.0
* Greatly improved eager-loaded support. You can now specify exactly which models
  you want to eagerLoad. It also supports eager-loaded many models of the same
  type.
* Introduced (possibly) backwards-compatibility-breaking change: Make sure, that
  all your Sequelize model definitions also specify an `as: "Model"` alias
  definition.

## Version 0.3.6
* Model.build() is able to initialize eagerly loaded associations

## Version 0.3.4
* Added possibility to search array fields for values in the controller

## Version 0.3.2
* Added Salad.Model.inspect() for console output
* Fixed a pagination mixin bug

## Version 0.3.1
* Added Model.increment() and Model.decrement() to increment or decrement fields
  of a model without concurrency issues.

## Version 0.2.18
* Added useful middleware for more detailed logging
* Dispatch request logging
* App.Logger.error now actually gets logged
* Better error handling for requests using nodejs domains

## Version 0.2.15
* Added ability to filter models in the request by adding ?where, ?sort
  and ?includes GET parameters

## Version 0.2.14
* Salad.Model hasAttribute method added
* [BUG] Load cakefile util class

## Version 0.2.13
* Common Cakefile helpers

## Version 0.2.12
* Handlebars partials are re-registered when they changed
* Salad.Validator can be used on the client-side
* Registered salad as bower package to ship client-assets

## Version 0.2.8
* Improved serialization of models when passed to handlebars
* Added validation method implementations and validate in the controllers
* Models can define default values of their attributes
* [BUG] Fixed ordering with newest sequelize version

## Version 0.2.7
* [BUG] Renamed @resource() to @resourceClass() to prevent name clashes
* [FEATURE] Error handler logs errors

## Version 0.2.6
* [BUG] Fixed serialization of data for templates

## Version 0.2.5
* [FEATURE] ability to register handlebar helpers
* [BUG] Fixed name of the key of eager-loaded associations
