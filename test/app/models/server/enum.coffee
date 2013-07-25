App.SequelizeEnum = App.sequelize.define "Enum",
  title: Sequelize.ENUM("A", "B")

class App.Enum extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeEnum


  @attribute "id"
  @attribute "title"
  @attribute "createdAt"
  @attribute "updatedAt"
