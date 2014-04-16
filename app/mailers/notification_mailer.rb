class NotificationMailer < ActionMailer::Base

  default from: "'Contributron Robot' <robot@contributron.io>"

  def notify_user(organization)
    @organization = organization
    subject = "News from contributron Organization: #{organization.name}"
    mail(:to => organization.user.email, :cc => "hecbuma@gmail.com", :subject => subject)
  end

end