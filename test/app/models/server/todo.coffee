attributes =
  id:
    type: Sequelize.INTEGER
    autoIncrement: true
    primaryKey: true
    allowNull: true

  title: Sequelize.STRING
  isDone: Sequelize.BOOLEAN

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
  @attribute "isDone", default: false
  @attribute "createdAt"
  @attribute "updatedAt"
  @attribute "completedAt"
