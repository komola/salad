App.SequelizeParent = App.sequelize.define "Parent",
  title: Sequelize.STRING

class App.Parent extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeParent

  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"