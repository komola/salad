App.SequelizeOperatorItemUser = App.sequelize.define "OperatorItemUser", {user: Sequelize.STRING},
  tableName: "operatoritemusers"

class App.OperatorItemUser extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperatorItemUser

  @attribute "id"
  @attribute "user"
  @attribute "createdAt"
  @attribute "updatedAt"
