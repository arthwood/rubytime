class UserMailer < ActionMailer::Base
  FROM = %Q(rubytime admin <#{ADMIN_EMAIL}>)
  
  def reset(user, sent_at = Time.now)
    @subject    = 'Reset your RubyTime password!'
    @body       = {:user => user}
    @recipients = user.email
    @from       = FROM
    @sent_on    = sent_at
    @headers    = {}
  end
end
