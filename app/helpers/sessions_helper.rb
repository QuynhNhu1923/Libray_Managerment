module SessionsHelper
  # Logs in the given user.
  def log_in user
    session[:user_id] = user.id
  end

  def logged_in?
    current_user.present?
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_out
    forget current_user
    delete_session_and_cookies
    @current_user = nil
  end

  def delete_session_and_cookies
    session.delete(:user_id)
    session.delete(:session_token)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    @current_user ||= find_user_from_session || find_user_from_cookies
  end

  def current_user? user
    user == current_user
  end

  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
    session[:session_token] = user.remember_token
  end

  def remember_session user
    user.remember
    session[:session_token] = user.remember_token
  end

  def redirect_back_or(default, **options)
    redirect_to(session[:forwarding_url] || default, **options)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  def find_user_from_session
    user_id = session[:user_id]
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    session_token = session[:session_token]
    user if user.authenticated?(:remember, session_token)
  end

  def find_user_from_cookies
    user_id = cookies.signed[:user_id]
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    return unless user.authenticated?(:remember, cookies[:remember_token])

    log_in user
    user
  end
end
