class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :label_metrics

  protected
 
  def switch_locale(&action)
    locale = session[:locale] || I18n.default_locale
    I18n.locale = locale
    I18n.with_locale(locale, &action)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :username, :avatar, :photo, :phone ])
  end

  def label_metrics
    Thread.current['metrics_labels'] = { controller: params[:controller], action: params[:action] }
    yield # call the action
  ensure
    # reset to nil so nothing else can access it
    Thread.current['metrics_labels'] = nil
  end
end
