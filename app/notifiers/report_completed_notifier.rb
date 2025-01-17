class ReportCompletedNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  deliver_by :email do |config| 
    config.mailer = "ReportMailer"
    config.method = :completed
  end

  required_params :report
  required_params :user

  def to_websocket
    {
      account_id: record.account_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "reports.report_completed", title: params[:report].title
  end

  def url
    report_path(params[:report].to_param)
  end
end
