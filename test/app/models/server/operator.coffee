App.SequelizeOperator = App.sequelize.define "Operator",
  title: Sequelize.STRING

App.SequelizeOperator.hasMany App.SequelizeLocation, as: "Locations", foreignKey: "operatorId"
App.SequelizeLocation.belongsTo App.SequelizeOperator, foreignKey: "operatorId"

class App.Operator extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperator

  @attributes:
    id: null
    title: null
    createdAt: null
    updatedAt: null

App.Operator.hasMany App.Location, as: "Locations", foreignKey: "operatorId"
App.Location.belongsTo App.Operator, as: "Operator", foreignKey: "operatorId"
