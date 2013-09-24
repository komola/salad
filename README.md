[![Build Status](https://travis-ci.org/komola/salad.png?branch=master)](https://travis-ci.org/komola/salad)

[![Dependency status](https://david-dm.org/komola/salad.png)](https://david-dm.org/komola/salad)

# Salad

Salad is supposed to be a very lightweight nodeJS framework, that brings the
possibility to register routes and controllers and use popular ORM frameworks like

* [Sequelize](http://www.sequelizejs.com/)

## Getting started

In your project, do this

    npm install salad

This is the basic directory setup you should have in your project:

```
    /app
      /collections # mostly Backbone collections
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
      /models
        /server
        /shared
        /client
      /templates
        /server
        /shared
        /client
      /views # Mostly for Backbone Views
        /client
    /public
      /assets

    /bower.json
    /Gruntfile.coffee
    /package.json
    /server.js
```

Salad is composed of several libraries, that are used to bring together useful
functionality.

* MarionetteJS
* Sequelize
* Grunt
* Bower

The whole application is instrumented using application configurations.
Configurations should register routes and according controllers.

## Brief "Getting started" guide

### Registering Routes

**/app/config/routes.coffee**

```coffeescript
Salad.Router.register (router) ->
  # register a full resources. Equivalent of
  # router.get('/photos(.:format)', 'GET').to('photos.index')
  # router.post('/photos(.:format)', 'POST').to('photos.create')
  # router.get('/photos/add(.:format)', 'GET').to('photos.add')

  # router.get('/photos/:'+resourceName+'Id(.:format)', 'GET').to('photos.show')
  # router.get('/photos/:'+resourceName+'Id/edit(.:format)', 'GET').to('photos.edit')
  # router.put('/photos/:'+resourceName+'Id(.:format)', 'PUT').to('photos.update')
  # router.del('/photos/:'+resourceName+'Id(.:format)', 'DELETE').to('photos.destroy')
  router.resource "photos", "photos", "photo"

  # registering a GET route and handle it in the index action of our index controller
  router.get("/index").to("index.index")
```

### Resourceful controller

**/app/controllers/server/usersController.coffee**

```coffeescript
class App.UsersController extends Salad.RestfulController

###
  A restful controller automatically implements CRUD actions like
  * index
  * create
  * update
  * destroy

  However, you can still replace the default actions. Take a look at
  salads src/controllers/concerns/actions.coffe file. This is where the
  default actions are defined.
###
```

### Models

You can define models like this: (notice, that the model definition will probably change in future salad versions)

**/app/models/server/todo.coffee**

```coffeescript
attributes =
  id:
    type: Sequelize.INTEGER
    autoIncrement: true
    primaryKey: true
    allowNull: true

  title: Sequelize.STRING

  createdAt: Sequelize.DATE
  updatedAt: Sequelize.DATE
  completedAt: Sequelize.DATE

options =
  tableName: "todos"

App.SequelizeTodo = App.sequelize.define "Todo", attributes, options

class App.Todo extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeTodo

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"
  @attribute "completedAt"
```

This basically defines a sequelize model, and passes the instance it
on to our salad model. This is required, because salad provides the
functionality to support many different data stores. So you could also
think about Facebook, MongoDB, etc.

The actual salad model definition is this part:

```coffeescript
class App.Todo extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeTodo

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"
  @attribute "completedAt"
```

this defines the model and some attributes.

In our salad application we could now do something like this:

```coffeescript
attributes =
  title: "I am a TODO item!"

App.Todo.create attributes, (err, resource) =>
  console.log resource.toJSON()
```

### Example of interacting with a model:

```coffeescript
App.Todo.create title: "Test", (err, resource) =>
  console.log resource.toJSON()

# Selecting a model by id
App.Todo.find 1, (err, resource) =>
  # accessing single attributes
  resource.get("id") # returns 1

  # getting all attributes
  resource.getAttributes() # returns an object with key, value pairs

  # setting a new title. This only changes the current instance. we
  # have to save our changes
  resource.set "title", "my new title"

  resource.save (err, savedResource) =>
    # we now saved our changes


    # but instead of using `model.set` and `model.save` we could do this:

    resource.updateAttributes title: "my new title", (err, savedResource) =>
      # this also saved our changes

```

### Querying models

Salad provides a mechanism called `scopes`. They are basically very dumb
instances that collect arguments like conditions, sort information, etc.

When finally comleting the scope, these objects are passed on to the DAO
instance. The DAO instance is responsible for translating the arguments
contained in the scope to form a request to its data provider.

To illustrate:

    App.Todo.asc("createdAt").limit(3).first

might produce an SQL query like this:

    SELECT * FROM "todos" ORDER BY createdAt ASC LIMIT 3

As you can see, you can chain different operators on the scope.

Possible operators are:

```coffeescript
model = App.Todo

# options is a hash object containing specific conditions
options =
  title: "test"
  completedAt: null

model.where(options)

# order ascending by title
model.asc("title")

# this can be called several times:
model.asc("title").asc("createdAt")

# same as with descending sorting
model.desc("title")

# checking if something is contained in an array (PostgreSQL i.e.)
# this checks if "work" is an element of the "tags" field.
model.contains("tags", "work")

# eager-loading of associated models
model.include([App.User])

# limiting result set
model.limit(30)

# skipping first 10 results
model.offset(10)
```

When you are done calling all the operators, you may finalize the scope.
You do this by calling the actual method that queries the data:

```coffeescript
model.where(completed: false).count (err, count) =>
  console.log count# 10

model.all (err, resources) =>
  # resources is an array containing the requested models

model.first (err, resource) =>
  # returns the first resource. Same as:
  model.limit(1).all (err, resources) =>
    resource = resources[1]

model.findAndCountAll (err, data) =>
  console.log data.count # 10
  console.log data.rows # Array containing resources
```

### Fixtures

Let's assume you have a `App.User` model and you want to have some instances
in the database for easy unit testing or just to have some data to show during
development.

You can create a file `test/fixtures/users.coffee`:

```coffeescript
module.exports = [
  {
    email: "user@domain.com"
    firstname: "Tom"
    lastname: "Bob"
  }
]
```

When you execute `cake db:load` the fixtures will get initialized and stored
in the database.

Fixtures make it very easy for you as a developer to quickly bootstrap some data.

# License
(MIT License)

Copyright (C) 2012, 2013 komola GmbH, Germany (Sebastian Hoitz <hoitz@komola.de>)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
