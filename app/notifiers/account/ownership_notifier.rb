class Account::OwnershipNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  required_params :previous_owner

  def to_websocket
    {
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "notifications.account_transferred", previous_owner: params[:previous_owner].name, account: account.name
  end

  def url
    account_path(account)
  end
end
