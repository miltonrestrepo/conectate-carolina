class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :set_locale
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action  :verify_authorized, unless: :devise_controller?

private

	def set_locale
		I18n.locale = params[:locale] if params[:locale].present?
	end

	def default_url_options(options = {})
		{locale: I18n.locale}
	end

  def user_not_authorized
    flash[:alert] = "Access denied"
    redirect_to (request.referrer || root_path)
  end

end
