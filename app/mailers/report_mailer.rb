class ReportMailer < ApplicationMailer
  def completed
    @report = params[:report]
    @user = params[:recipient]

    mail(
      to: email_address_with_name(@user.email, @user.name),
      from: email_address_with_name(Jumpstart.config.support_email, Jumpstart.config.support_email),
      subject: t(".subject", title: @report.title)
    )
  end
end
