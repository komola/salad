# Salad Changelog

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
