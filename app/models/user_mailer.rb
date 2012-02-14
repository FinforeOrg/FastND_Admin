class UserMailer < ActionMailer::Base
   def welcome_email(user,password)
     @recipients = user.login
     @from = "info@finfore.net"
     @subject = "FinforeNet - Welcome to finforeNet"
     @sent_on = Time.now
     @content_type = "text/html"
     @body = {:user => user, 
              :download_url => "http://www.finfore.net/download.html",
              :home_url => "http://www.finfore.net/",
              :password => password
             }
   end

   def new_user_to_admin(user)
     @recipients = "shane@finfore.net, info@finfore.net"
     @from = "info@finfore.net"
     @subject = "FinforeNet - Congratulation New User Signed Up"
     @sent_on = Time.now
     @content_type = "text/html"
     @body = {:user => user}
   end

   def contact(to, subject, options)
     @recipients = to
     @from = options[:email]
     @subject = subject
     @sent_on = Time.now
     @content_type = "text/html"
     @body = options
   end
   
   def forgot_password(user,new_password)
     @recipients = user.login
     @from = "info@finfore.net"
     @subject = "FinforeNet - Forgot Password and Email"
     @sent_on = Time.now
     @content_type = "text/html"
    @body = {:login_email => user.login, :password => new_password}
   end

   def alert_duplication(user,reports)
     @recipients = "shane@finfore.net"
     @from = "info@finfore.net"
     @subject = "FinforeNet - Focuses duplication on public profiles"
     @sent_on = Time.now
     @content_type = "text/html"
     @body = {:login => user.login,
              :reports => reports}
   end

end
