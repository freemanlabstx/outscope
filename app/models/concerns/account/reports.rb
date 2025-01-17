module Account::Reports
  extend ActiveSupport::Concern

  included do
    has_many :reports, dependent: :destroy
    validate :can_create_report?, on: :create
    scope :sorted, -> { order(created_at: :desc) }
  end

  def can_create_report?
    # Haven't made a report in the last 24 hours
    reports.where('created_at > ?', 24.hours.ago).count.zero?
  end
end
