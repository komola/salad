App.SequelizeShop = App.sequelize.define "Shop",
  title: Sequelize.ARRAY(Sequelize.STRING)
  anotherTitle: Sequelize.ARRAY(Sequelize.STRING)
  otherField: Sequelize.STRING

class App.Shop extends Salad.Model
  @dao
    type: "sequelize"
    instance: App.SequelizeShop

  @attribute "id"
  @attribute "title"
  @attribute "anotherTitle"
  @attribute "otherField"
  @attribute "createdAt"
  @attribute "updatedAt"
