class PasswordResetsController < ApplicationController
  before_action :load_user_for_create, only: :create
  before_action :check_user_activated, only: :create
  before_action :load_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_empty_password, only: %i(update)

  # GET /password_resets/new
  def new; end

  # GET /password_resets/:id/edit
  def edit; end

  # POST /password_resets
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".email_sent")
    redirect_to root_path
  end

  # PATCH /password_resets/:id
  def update
    if @user.update(user_params.merge(reset_digest: nil))
      log_in @user
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit User::USER_PERMIT_FOR_PASSWORD_RESET
  end

  def load_user_for_create
    email = params.dig(:password_reset, :email)&.downcase
    @user = User.find_by(email:)
    return if @user

    flash.now[:danger] = t(".email_not_found")
    render :new, status: :unprocessable_entity
  end

  def check_user_activated
    return if @user.activated?

    flash.now[:danger] = t(".account_not_activated")
    render :new, status: :unprocessable_entity
  end

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".not_found")
    redirect_to root_path
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t(".user_not_activated")
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_url
  end

  def check_empty_password
    return unless user_params[:password].empty?

    @user.errors.add :password, t(".password_blank")
    render :edit, status: :unprocessable_entity
  end
end
