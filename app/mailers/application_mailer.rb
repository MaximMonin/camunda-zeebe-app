class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@' + ENV['VIRTUAL_HOST']
  layout 'mailer'
end
