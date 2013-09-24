require "./parent"

App.SequelizeChild = App.sequelize.define "Child",
  {title: Sequelize.STRING}
  {tableName: "children"}

App.SequelizeParent.hasMany App.SequelizeChild, foreignKey: "parentId"
App.SequelizeChild.belongsTo App.SequelizeParent, as: "Parent", foreignKey: "parentId"


class App.Child extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeChild

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"


App.Parent.hasMany App.Child, as: "Children", foreignKey: "parentId"
App.Child.belongsTo App.Parent, as: "Parent", foreignKey: "parentId"