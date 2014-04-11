class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate!

  helper_method :current_user


  private

  def current_user
    @current_user ||= User.where(:id => session[:user_id]).first
  end

  def authenticate!
    unless current_user
      flash[:notice] = 'You have to be logged in'
      redirect_to root_url
    else
      redirect_to dashboard_index_path, alert: "You have already logged in"
    end
  end




end
