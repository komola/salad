App.SequelizeShop = App.sequelize.define "Shop",
  title: Sequelize.ARRAY(Sequelize.STRING)
  foo: Sequelize.STRING

class App.Shop extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeShop

  @attributes:
    id: null
    title: null
    foo: null
    createdAt: null
    updatedAt: null