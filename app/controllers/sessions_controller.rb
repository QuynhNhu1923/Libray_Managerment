class SessionsController < ApplicationController
  before_action :find_user_and_validate, only: %i(create)
  before_action :check_activeted, only: %i(create)
  REMEMBER_ME_SELECTED = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    login_success(@user)
  end

  # DELETE /logout
  def destroy
    log_out
    flash[:success] = t(".success")
    redirect_to root_url, status: :see_other
  end

  private

  def find_user_and_validate
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)

    return if @user&.authenticate(params.dig(:session, :password))

    login_failed
  end

  def login_failed
    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end

  def check_activeted
    return if @user.activated?

    flash[:warning] = t(".not_activated")
    redirect_to root_url, status: :see_other
  end

  def login_success user
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    session[:forwarding_url] = forwarding_url if forwarding_url
    if params.dig(:session,
                  :remember_me) == REMEMBER_ME_SELECTED
      remember user
    else
      remember_session user
    end
    flash[:success] = t(".success")
    redirect_back_or user_path(user), status: :see_other
  end
end
