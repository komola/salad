sequelizeLocation = App.sequelize.define "Location",
  title: Sequelize.STRING
  description: Sequelize.TEXT
  messages: Sequelize.INTEGER

sequelizeLocation.hasMany sequelizeLocation, as: "Children", foreignKey: "parentId"
sequelizeLocation.belongsTo sequelizeLocation, as: "Parent", foreignKey: "parentId"

class App.Location extends Salad.Model
  @dao
    type: "sequelize"
    instance: sequelizeLocation

  @attributes:
    id: undefined
    title: undefined
    description: undefined
    messages: undefined
    createdAt: undefined
    updatedAt: undefined

App.Location.hasMany App.Location, as: "Children", foreignKey: "parentId"
App.Location.belongsTo App.Location, as: "Parent", foreignKey: "parentId"
