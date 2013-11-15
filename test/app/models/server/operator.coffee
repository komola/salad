require "./operatorItem"

App.SequelizeOperator = App.sequelize.define "Operator",
  title: Sequelize.STRING

App.SequelizeOperator.hasMany App.SequelizeLocation, as: "Locations", foreignKey: "operatorId"
App.SequelizeLocation.belongsTo App.SequelizeOperator, as: "Operator", foreignKey: "operatorId"

App.SequelizeOperator.hasMany App.SequelizeLocation, as: "SupportLocations", foreignKey: "support_operatorId"
App.SequelizeLocation.belongsTo App.SequelizeOperator, as: "SupportOperator", foreignKey: "support_operatorId"

App.SequelizeOperator.hasMany App.SequelizeOperatorItem, as: "OperatorItems", foreignKey: "operatorId"
App.SequelizeOperatorItem.belongsTo App.SequelizeOperator, foreignKey: "operatorId"

class App.Operator extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperator

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"

App.Operator.hasMany App.Location, as: "Locations", foreignKey: "operatorId"
App.Location.belongsTo App.Operator, as: "Operator", foreignKey: "operatorId"
App.Operator.hasMany App.OperatorItem, as: "OperatorItems", foreignKey: "operatorId"
App.OperatorItem.belongsTo App.Operator, as: "Operator", foreignKey: "operatorId"
App.Operator.hasMany App.Location, as: "SupportLocations", foreignKey: "support_operatorId"
App.Location.belongsTo App.Operator, as: "SupportOperator", foreignKey: "support_operatorId"
