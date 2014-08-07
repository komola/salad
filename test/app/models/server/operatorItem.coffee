require "./operatorItemStatus"

App.SequelizeOperatorItem = App.sequelize.define "OperatorItem", {data: Sequelize.STRING},
  tableName: "operatoritems"

App.SequelizeOperatorItem.hasMany App.SequelizeOperatorItemStatus, as: "OperatorItemStatus", foreignKey: "operatorItemId"
App.SequelizeOperatorItemStatus.belongsTo App.SequelizeOperatorItem, as: "OperatorItem", foreignKey: "operatorItemId"

class App.OperatorItem extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperatorItem

  @attribute "id"
  @attribute "data"
  @attribute "createdAt"
  @attribute "updatedAt"


App.OperatorItem.hasMany App.OperatorItemStatus, as: "OperatorItemStatus", foreignKey: "operatorItemId"
App.OperatorItemStatus.belongsTo App.OperatorItem, as: "OperatorItem", foreignKey: "operatorItemId"
