class WelcomeController < ApplicationController
  def index
  end
# Init Vue.js Vuex.Stote
  def initstore
    user = current_user
    respond_to do |format|
      msg = { :lang => I18n.locale, :user => user, :baseurl => request.base_url, :servertime => DateTime.now.strftime("%Q") }
      format.json  { render :json => msg } 
    end
  end
end
