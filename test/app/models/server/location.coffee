sequelizeLocation = App.sequelize.define "Location",
  title: Sequelize.STRING
  description: Sequelize.TEXT
  messages: Sequelize.INTEGER

class App.Location extends Salad.Model
  @dao
    type: "sequelize"
    instance: sequelizeLocation

  attributes:
    id: undefined
    title: undefined
    description: undefined
    messages: undefined
