require "./operatorItem"

App.SequelizeOperator = App.sequelize.define "Operator",
  title: Sequelize.STRING

App.SequelizeOperator.hasMany App.SequelizeLocation, as: "Locations", foreignKey: "operatorId"
App.SequelizeLocation.belongsTo App.SequelizeOperator, foreignKey: "operatorId"

App.SequelizeOperator.hasMany App.SequelizeOperatorItem, foreignKey: "operatorId"
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
