App.SequelizeEnum = App.sequelize.define "Enum",
  title: Sequelize.ENUM("A", "B")

class App.Enum extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeEnum

  @attributes:
    id: null
    title: null
    createdAt: null
    updatedAt: null
