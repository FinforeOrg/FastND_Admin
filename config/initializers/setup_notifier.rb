FinforeAdmin::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[ADMIN ERROR] ",
  :sender_address => '"Admin Notifier" <notifier@fastnd.com>',
  :exception_recipients => ['yacobus.reinhart@gmail.com','behtea@gmail.com']
