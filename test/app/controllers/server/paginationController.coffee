class App.PaginationController extends Salad.RestfulController
  @resource "location"

  @pagination()

  index: ->
    if @params.error
      return @render json: {error: "Not allowed"}, status: 401

    super
