source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#######################################################################
# Rails addon gems
# Job processing, auth, pagination, image/video processing, audit, search
# simple-forms, sms, file upload, file storage, localization, monitoring
#######################################################################
gem 'sidekiq', '>= 6'
gem 'prometheus_exporter'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'audited', '~> 4.9'
gem 'devise'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-vkontakte'
gem 'omniauth-github'
gem 'will_paginate', '>= 3'
gem 'image_processing', '~> 1.2'
gem 'streamio-ffmpeg', '>= 2'
gem 'simple_form'
gem 'font-awesome-sass'
gem 'turbosms'
gem 'dotenv-rails'
gem 'carrierwave', '>= 2.0'
gem 'aws-sdk-s3'
gem 'activestorage-sftp'
gem 'rails-i18n', '~> 6.0.0'
gem 'carrierwave-i18n'
gem 'devise-i18n'
gem 'will-paginate-i18n'

group :development, :test do
  gem 'faker'
end
