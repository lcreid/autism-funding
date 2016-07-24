class FormsController < ApplicationController
  def index
    @forms = current_user.forms.all
  end
end
