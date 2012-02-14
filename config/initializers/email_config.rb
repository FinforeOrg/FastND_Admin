# STAGING : api.finfore.net
# LIVE    : live.finfore.net

ActionMailer::Base.default_url_options[:host] = "live.finfore.net"

ActionMailer::Base.smtp_settings = {
  :address => "secure.emailsrvr.com",
  :port => 587,
  :domain => "fastnd.com",
  :authentication => :plain,
  :user_name => "info@fastnd.com",
  :password => "44London",
  :enable_starttls_auto => true
}


