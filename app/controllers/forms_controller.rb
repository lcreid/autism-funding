class FormsController < ApplicationController
  def index
    @forms = Cf0925.all
  end
end
