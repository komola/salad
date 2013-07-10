App.SequelizeParent = App.sequelize.define "Parent",
  title: Sequelize.STRING

class App.Parent extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeParent

  @attributes:
    id: null
    title: null
    createdAt: null
    updatedAt: null
