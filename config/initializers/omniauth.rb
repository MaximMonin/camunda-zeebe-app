Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET'], image_size: 'large'
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], { scope: 'userinfo.email,userinfo.profile', image_size: 200, name: 'google' }
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET'],  { :image_size => 'original' }
  provider :github, ENV['GITHUB_ID'], ENV['GITHUB_SECRET']
  provider :vkontakte, ENV['VK_ID'], ENV['VK_SECRET'], scope: 'email', image_size: 'original', lang: 'ru'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  on_failure { |env| SocialsController.action(:failure).call(env) }
end
