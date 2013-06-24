App.SequelizeLocation = App.sequelize.define "Location",
  title: Sequelize.STRING
  description: Sequelize.TEXT
  messages: Sequelize.INTEGER

App.SequelizeLocation.hasMany App.SequelizeLocation, as: "Children", foreignKey: "parentId"
App.SequelizeLocation.belongsTo App.SequelizeLocation, as: "Parent", foreignKey: "parentId"

class App.Location extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeLocation

  @attributes:
    id: null
    title: null
    description: null
    messages: null
    createdAt: null
    updatedAt: null

App.Location.hasMany App.Location, as: "Children", foreignKey: "parentId"
App.Location.belongsTo App.Location, as: "Parent", foreignKey: "parentId"
