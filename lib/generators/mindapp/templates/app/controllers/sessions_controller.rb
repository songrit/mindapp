# encoding: utf-8
class SessionsController < ApplicationController
  def new
    @title= 'Sign In'
  end

  # to refresh the page, must know BEFOREHAND that the action needs refresh
  # then use attribute 'data-ajax'=>'false'
  # see app/views/sessions/new.html.erb for sample
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to '/mindapp/pending'
  rescue
    redirect_to root_path, :alert=> "Authentication failed, please try again."
  end

  def destroy
    session[:user_id] = nil
    # redirect_to '/mindapp/help'
    refresh_to root_path
    #  render not work!!
    #redirect_to 'mindapp/index'
  end

  def failure
    ma_log "Authentication failed, please try again."
    redirect_to root_path, :alert=> "Authentication failed, please try again."
  end
end
