class ApplicationController < ActionController::Base
  def require_current_user
    return if current_user

    redirect_to login_path
  end

  def current_user
    current_user ||= User.find_by(id: session_user_id)
  end

  def session_user_id
    session[:user_id]
  end
end
