App.SequelizeParent = App.sequelize.define "Parent",
  title: Sequelize.STRING
  otherTitle: Sequelize.ARRAY(Sequelize.STRING)

class App.Parent extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeParent

  @attribute "id"
  @attribute "title"
  @attribute "otherTitle"
  @attribute "createdAt"
  @attribute "updatedAt"

App.Parent.hasMany App.Child, as: "Children", foreignKey: "parentId"