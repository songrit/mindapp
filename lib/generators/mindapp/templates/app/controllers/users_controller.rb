class UsersController < ApplicationController
  def index
    @today = Date.today
    @xmains = current_user.xmains.in(status:['R','I']).asc(:created_at)
  end

  # mindapp methods
  def update_user
    # can't use session, current_user inside mindapp methods
    $user.update_attribute :email, $xvars["enter_user"]["user"]["email"]
  end
end
