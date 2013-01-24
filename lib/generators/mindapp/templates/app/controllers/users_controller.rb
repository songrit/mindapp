# -*- encoding : utf-8 -*-
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
  def change_password
    # check if old password correct
    identity = Identity.find_by :code=> $user.code
    if identity.authenticate($xvars["enter"]["epass"])
      identity.password = $xvars["enter"]["npass"]
      identity.password_confirmation = $xvars["enter"]["npass_confirm"]
      identity.save
      ma_log "Password changed"
    else
      ma_log "Unauthorized access"
    end
  end
end
