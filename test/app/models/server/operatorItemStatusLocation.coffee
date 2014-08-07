App.SequelizeOperatorItemStatusLocation = App.sequelize.define "OperatorItemStatusLocation", {location: Sequelize.STRING},
  tableName: "operatoritemstatuslocations"

class App.OperatorItemStatusLocation extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperatorItemStatusLocation

  @attribute "id"
  @attribute "location"
  @attribute "createdAt"
  @attribute "updatedAt"
