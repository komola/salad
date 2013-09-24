attributes =
  id:
    type: Sequelize.INTEGER
    autoIncrement: true
    primaryKey: true
    allowNull: true

  field: Sequelize.STRING

  createdAt: Sequelize.DATE
  updatedAt: Sequelize.DATE

App.SequelizeValidation = App.sequelize.define "Validation", attributes

class App.Validation extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeValidation

  @attribute "id"
  @attribute "field"
  @attribute "createdAt"
  @attribute "updatedAt"

  isValid: (attributes) ->
    return true if attributes.field is "valid"

    field: "Not valid"
