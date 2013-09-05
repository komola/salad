App.SequelizeOperatorItem = App.sequelize.define "OperatorItem", {data: Sequelize.STRING},
  tableName: "operatoritems"

class App.OperatorItem extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeOperatorItem

  @attribute "id"
  @attribute "data"
  @attribute "createdAt"
  @attribute "updatedAt"
