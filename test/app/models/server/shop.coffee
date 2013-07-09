App.SequelizeShop = App.sequelize.define "Shop",
  title: Sequelize.ARRAY(Sequelize.STRING)
  anotherTitle: Sequelize.ARRAY(Sequelize.STRING)
  otherField: Sequelize.STRING

class App.Shop extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeShop

  @attributes:
    id: null
    title: null
    anotherTitle: null
    otherField: null
    createdAt: null
    updatedAt: null