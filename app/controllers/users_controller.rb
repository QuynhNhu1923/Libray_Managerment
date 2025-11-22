class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update)
  before_action :load_user, only: %i(show edit update)
  before_action :correct_user, only: %i(edit update)

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      send_activation_email
    else
      flash.now[:danger] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id
  def show; end

  # GET /users/:id/edit
  def edit; end

  # PATCH/PUT /users/:id
  def update
    if @user.update user_params
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t(".not_found")
    redirect_to root_path, status: :see_other
  end

  def user_params
    params.require(:user).permit(User::USER_PERMIT)
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t(".please_login")
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t(".not_correct_user")
    redirect_to root_url
  end

  def send_activation_email
    @user.send_activation_email
    flash[:info] = t(".check_email")
    redirect_to root_path, status: :see_other
  rescue StandardError
    flash[:danger] = t(".email_error")
    redirect_to root_path, status: :see_other
  end
end
