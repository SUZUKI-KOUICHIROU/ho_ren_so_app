class Report < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :report_confirmers, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true
  attribute :remanded, default: false
  attribute :resubmitted, default: false

  # validates :report_detail, presence: true
  validates :title, presence: true, length: { maximum: 30 }
  validates :report_day, presence: true
  validates :sender_name, presence: true

  def self.befor_deadline_reports_size(project_reports)
    if project_reports.present?
      return project_reports.map { |report| report.report_day == report.created_at.to_date ? report.user_id : nil }.compact.uniq.size
    else
      return 0
    end
  end
end
