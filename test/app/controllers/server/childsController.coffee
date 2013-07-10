class App.ChildsController extends Salad.RestfulController
  @resource "child"

  @belongsTo "parent"
