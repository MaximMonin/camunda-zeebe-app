class SocialsController < ApplicationController
  before_action :authenticate_user!, :except => [:create]

  def destroy
    # remove an authentication service linked to the current user
    @social = current_user.socials.find(params[:id])
    @social.destroy
 
    redirect_back fallback_location: root_path
  end
 
  def create
    ActiveRecord::Base.connected_to(role: :writing) do
      omniauth = request.env['omniauth.auth']
      provider = omniauth['provider']
      uid = omniauth['uid']
      email = omniauth['info']['email']
      name = omniauth['info']['name']
      photo = omniauth['info']['image']
      weblink = getlink(provider, omniauth)
  
      # continue only if provider and uid exist
      if uid != '' and provider != ''     
        # nobody can sign in twice, nobody can sign up while being signed in (this saves a lot of trouble)
        if !user_signed_in?    
          # check if user has already signed in using this service provider and continue with sign in process if yes
          auth = Social.find_by_provider_and_uid(provider, uid)
          if auth
            flash[:notice] = t(".signed_in_successfully_via") + ' ' + provider.capitalize + '.'
            sign_in_and_redirect(:user, auth.user)
          else
            # check if this user is already registered with this email address; get out if no email has been provided
            if email != '' and name != ''
              # search for a user with this email address
              existinguser = User.find_by_email(email)
              if existinguser
                # map this new login method via a service provider to an existing account if the email address is the same
                existinguser.socials.create(:provider => provider, :uid => uid, :username => name, :email => email, :data => omniauth, :weblink => weblink)
                flash[:notice] = t(".sign_in_via") + ' ' + provider.capitalize + ' ' + t(".has_been_added_to_your_account") + ' ' + existinguser.email + '. ' + t(".signed_in_successfully")
                sign_in_and_redirect(:user, existinguser)
              else
                # let's create a new user: register this user and add this authentication method for this user
                name = name[0, 39] if name.length > 39             # otherwise our user validation will hit us
   
                # new user, set email, a random password and take the name from the authentication service
                user = User.new :email => email, :password => SecureRandom.hex(10), :username => name, :has_local_password => false

                # add this authentication service to our new user
                user.socials.build(:provider => provider, :uid => uid, :username => name, :email => email, :data => omniauth, :weblink => weblink)
   
                # do not send confirmation email, we directly save and confirm the new record
                user.skip_confirmation!
                user.save!
                user.confirm

                # Attach avatar from social network
                url = URI.parse(photo)
                filename = File.basename(url.path)
                file = URI.open(photo)
                user.photo.attach(io: file, filename: filename)
                user.avatar = url_for(user.photo.variant(resize_to_limit: [300, 300]).processed) if user.photo.attached?
                user.save
   
                # flash and sign in
                flash[:notice] = t(".your_account_has_been_created_via") + ' ' + provider.capitalize + '. ' + t(".createinfo")
                sign_in_and_redirect(:user, user)
              end
            else
              flash[:alert] =  provider.capitalize + ' ' + t(".error_no_email") + ' ' + proviver.capitalize + ' ' + t(".error_no_email2")
              redirect_to new_user_session_path
            end
          end
        else
          # the user is currently signed in
          
          # check if this service is already linked to his/her account, if not, add it
          auth = Social.find_by_provider_and_uid(provider, uid)
          if !auth
            current_user.socials.create(:provider => provider, :uid => uid, :username => name, :email => email, :data => omniauth, :weblink => weblink )
            flash[:notice] = t(".sign_in_via") + ' ' + provider.capitalize + ' ' + t(".has_been_added_to_your_account") + '.'
            redirect_to edit_user_registration_path
          else
            flash[:notice] = provider.capitalize + ' ' + t(".is_already_linked_to_your_account") + '.'
            redirect_to edit_user_registration_path
          end  
        end  
      else
        flash[:alert] =  provider.capitalize + ' ' + t(".error_invalid_uid") 
        redirect_to new_user_session_path
      end
    end
  end

  def failure
    set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to new_user_session_path
  end

  protected

  def failed_strategy
    request.respond_to?(:get_header) ? request.get_header("omniauth.error.strategy") : request.env["omniauth.error.strategy"]
  end

  def set_flash_message(key, kind, options = {})
    message = options[:kind] + ": " + options[:reason]
    if options[:now]
      flash.now[key] = message if message.present?
    else
      flash[key] = message if message.present?
    end
  end

  def failure_message
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    error   = exception.error_reason  if exception.respond_to?(:error_reason)
    error ||= exception.error         if exception.respond_to?(:error)
    error ||= (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : request.env["omniauth.error.type"]).to_s
    error.to_s.humanize if error
  end

  def getlink(provider, data)
    weblink = ''
    urls = data['info']['urls'] if data['info']['urls'].present?
    if provider == 'facebook'
      weblink = 'https://facebook.com'
    end
    if provider == 'google'
      weblink = 'https://account.google.com'
    end
    if provider == 'twitter'
      weblink = 'https://twitter.com'
      weblink = urls['Twitter'] if urls && urls['Twitter'].present?
    end
    if provider == 'vkontakte'
      weblink = 'https://vk.com'
      weblink = urls['Vkontakte'] if urls && urls['Vkontakte'].present?
    end
    if provider == 'github'
      weblink = 'https://github.com'
      weblink = urls['GitHub'] if urls && urls['GitHub'].present?
    end
    return weblink
  end
end
