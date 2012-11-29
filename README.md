# Salad

Salad is supposed to be a very lightweight nodeJS framework, that brings the
possibility to register routes and controllers and use popular ORM frameworks like

* [Sequelize] (http://www.sequelizejs.com/)

## Getting started

  npm install salad

This is the basic directory setup:

    /app
      /config
        /routes.coffee
      /controllers
        ...
    /public
    /server.coffee

### Registering Routes

**/app/config/routes.coffee**

```coffeescript
Salad.Router.register ->
  @resource "/photo", controller: "photos"
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