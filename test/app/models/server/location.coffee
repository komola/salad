attributes =
  title: Sequelize.STRING
  description: Sequelize.TEXT
  messages: Sequelize.INTEGER
  parentId:
    type: Sequelize.INTEGER
    references: 
      model: "locations"
    onDelete: "restrict"
    onUpdate: "cascade"

options =
  tableName: "locations"

App.SequelizeLocation = App.sequelize.define "Location", attributes, options

App.SequelizeLocation.hasMany App.SequelizeLocation, as: "Children", foreignKey: "parentId"
App.SequelizeLocation.belongsTo App.SequelizeLocation, as: "Parent", foreignKey: "parentId"

class App.Location extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeLocation

  @attribute "id"
  @attribute "title"
  @attribute "description"
  @attribute "messages"
  @attribute "createdAt"
  @attribute "updatedAt"

App.Location.hasMany App.Location, as: "Children", foreignKey: "parentId"
App.Location.belongsTo App.Location, as: "Parent", foreignKey: "parentId"
