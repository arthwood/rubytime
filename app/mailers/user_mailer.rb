class UserMailer < ActionMailer::Base
  default :from => "rubytime admin <#{CONFIG[:admin][:email]}>"
  
  def reset(user, sent_at = Time.now)
    @subject    = 'Reset your RubyTime password!'
    @body       = {:user => user}
    @recipients = user.email
    @sent_on    = sent_at
    @headers    = {}
  end
end
