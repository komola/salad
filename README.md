# Salad

Salad is supposed to be a very lightweight nodeJS framework, that brings the
possibility to register routes and controllers and use popular ORM frameworks like

* [Sequelize](http://www.sequelizejs.com/)

## Roadmap

### Controllers
- [x] basic controllers
- [x] render JSON data
- [ ] allow to implement @before filters to execute special logic before an action is executed
- [ ] implement more robust rendering logic (replacable JSON and html renderers, other formats possible, too)
- [ ] develop better system for storing metadata in controllers, similar to towers `@metadata()` object
- [ ] support rendering HTML to the client


### Models
- [x] implement model layer that will wrap other models (i.e. Sequelize, Mongoose or other stuff, like Facebook)
- [x] implement association support
- [ ] allow to implement `@before`/`@after` actions for hooking into actions
- [ ] refactor the way models define attributes, transitioning to an API like @field "name", "type"

### General
- [ ] implement a modular construct, where modules provide custom models, controllers, etc.
- [ ] refactor bootstrap flow. Implement an event system, where a user can hook into the initialization `@after "init", (done) ->`

## Getting started

  npm install salad

This is the basic directory setup:

```
    /app
      /collections
        /server
        /shared
        /client
      /config
        /server
          /routes.coffee
        /shared
        /client
      /controllers
        /server
        /shared
        /client
        /concerns
          /server
          /shared
          /client
      /helpers
        /server
        /shared
        /client
      /lib
        /server
        /shared
        /client
      /models
        /server
        /shared
        /client
        /concerns
          /server
          /shared
          /client
      /templates
        /server
        /shared
        /client
      /translations
        /de_DE
        /...
      /views # Mostly for Backbone Views
        /client
    /public
      /assets
        /img
        /js
        /css
    /vendor

    /components.json
    /grunt.coffee
    /package.json
    /server.coffee
```

Salad is composed of several libraries, that are used to bring together useful
functionality.

* BackboneJS
* Sequelize
* Connect
  * Connect-Assets
* Grunt
* Bower

The whole application should be instrumented using application configurations.
Configurations should register routes and according controllers.

![NodeJS Holy Grail](http://s3.amazonaws.com/files.posterous.com/temp-2012-10-01/kdFEIqbgcujohgnuzHGvqcJquloxdwBnkvejGFdiCnFuznwiiyHIzafebBhr/shared-js-app.png.scaled1000.png?AWSAccessKeyId=AKIAJFZAE65UYRT34AOQ&Expires=1360508957&Signature=tpGKAAlqOkQQcwBmirWURbcT4vI%3D)

Our server side application won't talk to an API though, but to Sequelize as our ORM
library that stores the data.

```
 +--------------+      +---------------+     +--------------------+
 |Backbone Model|  --> |Storage Adapter| --> |Sequelize/Server API|
 +--------------+      +---------------+     +--------------------+
```

### Registering Routes

**/app/config/routes.coffee**

```coffeescript
Salad.Router.register (router) ->
  router.resource "/photos", "photos", "photo"
```

### Basic controller

**/app/controllers/HelloController.coffee**

```coffeescript
class App.HelloController extends Salad.Controller
```

# License
(MIT License)

Copyright (C) 2012 komola GmbH, Germany (Sebastian Hoitz <hoitz@komola.de>)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.