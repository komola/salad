require "./operatorItemStatusLocation"

App.SequelizeOperatorItemStatus = App.sequelize.define "OperatorItemStatus", {status: Sequelize.STRING},
  tableName: "operatoritemstatus"

App.SequelizeOperatorItemStatus.hasMany App.SequelizeOperatorItemStatusLocation, as: "OperatorItemStatusLocations", foreignKey: "operatorItemStatusId"
App.SequelizeOperatorItemStatusLocation.belongsTo App.SequelizeOperatorItemStatus, as: "OperatorItemStatus", foreignKey: "operatorItemStatusId"

class App.OperatorItemStatus extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperatorItemStatus

  @attribute "id"
  @attribute "status"
  @attribute "createdAt"
  @attribute "updatedAt"

App.OperatorItemStatus.hasMany App.OperatorItemStatusLocation, as: "OperatorItemStatusLocations", foreignKey: "operatorItemStatusId"
App.OperatorItemStatusLocation.belongsTo App.OperatorItemStatus, as: "OperatorItemStatus", foreignKey: "operatorItemStatusId"
