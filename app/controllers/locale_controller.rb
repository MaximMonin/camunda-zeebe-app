class LocaleController < ApplicationController
  def set
    lang = params[:locale]
    raise 'unsupported locale' unless ['en', 'ru', 'uk' ].include?(lang)
    I18n.locale = lang
    session[:locale] = lang
    redirect_back fallback_location: root_path
  end
end
