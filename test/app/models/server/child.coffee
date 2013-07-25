require "./parent"

App.SequelizeChild = App.sequelize.define "Child",
  title: Sequelize.STRING

App.SequelizeParent.hasMany App.SequelizeChild, as: "Children", foreignKey: "parentId"
App.SequelizeChild.belongsTo App.SequelizeParent, as: "Parent", foreignKey: "parentId"


class App.Child extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeChild

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"

App.Child.belongsTo App.Parent, as: "Parent", foreignKey: "parentId"
App.Parent.hasMany App.Child, as: "Children", foreignKey: "parentId"
