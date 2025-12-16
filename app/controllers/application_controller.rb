class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include SessionsHelper
  include Pagy::Backend
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_authorization_check if controller_path.start_with?("rails/active_storage")
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def admin_user
    return if current_user&.admin?

    redirect_to root_url, alert: t("admin.books.flash.access_denied")
  end

  private

  def set_locale
    allowed = I18n.available_locales.map(&:to_s)

    I18n.locale =
      if allowed.include?(params[:locale])
        params[:locale]
      else
        I18n.default_locale
      end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i(name date_of_birth gender))
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i(name date_of_birth gender))
  end
end
