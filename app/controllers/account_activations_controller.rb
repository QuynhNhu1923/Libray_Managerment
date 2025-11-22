class AccountActivationsController < ApplicationController
  before_action :load_user, only: %i(edit)
  before_action :check_authentication, only: %i(edit)
  # GET /account_activations/:id/edit
  def edit
    user_successfully_activated
  end

  private

  def user_successfully_activated
    @user.activate
    @user.remember
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user
  end

  def check_authentication
    return if !@user.activated && @user.authenticated?(:activation, params[:id])

    flash[:danger] = t(".error")
    redirect_to root_url
  end

  def load_user
    @user = User.find_by(email: params[:email])
    return if @user

    flash[:danger] = t(".error")
    redirect_to root_url
  end
end
