class UserMailer < ActionMailer::Base
  default :from => "rubytime admin <#{CONFIG[:admin][:email]}>"
  default_url_options[:host] = CONFIG[:hostname]
  
  def reset(user, sent_at = Time.now)
    @subject    = 'Reset your RubyTime password!'
    @user       = user
    @recipients = user.email
    @sent_on    = sent_at
    @headers    = {}
  end
end
