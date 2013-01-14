class UsersController < ApplicationController
  def index
    @today = Date.today
    @xmains = current_user.xmains.in(status:['R','I']).asc(:created_at)
  end
end
