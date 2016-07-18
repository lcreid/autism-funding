class Cf0925sController < ApplicationController
  def index
    @cf0925s = Cf0925.all
  end

  def new
    @cf0925 = Cf0925.new
  end

  def create
    @cf0925 = Cf0925.new(cf0925_params)
    if @cf0925.save
      redirect_to cf0925_path(@cf0925)
    else
      render :new
    end
  end

  def show
    @cf0925 = Cf0925.find(params[:id])
  end

  private

  def cf0925_params
    params
      .require(:cf0925)
      .permit(Cf0925.column_names)
  end
end
