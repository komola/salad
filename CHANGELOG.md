# Salad Changelog

## Version 0.2.8
* Improved serialization of models when passed to handlebars
* Added validation method implementations and validate in the controllers
* Models can define default values of their attributes

## Version 0.2.7
* [BUG] Renamed @resource() to @resourceClass() to prevent name clashes
* [FEATURE] Error handler logs errors

## Version 0.2.6
* [BUG] Fixed serialization of data for templates

## Version 0.2.5
* [FEATURE] ability to register handlebar helpers
* [BUG] Fixed name of the key of eager-loaded associations