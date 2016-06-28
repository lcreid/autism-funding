class Cf0925sController < ApplicationController
  def create
    @cf0925 = Cf0925.new(cf0925_params)
    @cf0925.save
    redirect_to cf0925_path(@cf0925)
  end

  private

  def cf0925_params
    params
      .require(:cf0925)
      .permit(Cf0925.column_names)
  end
end
