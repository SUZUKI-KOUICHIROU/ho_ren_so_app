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

  scope :search, ->(search_params) do
    return all if search_params.blank?

    reports = all

    if search_params[:title].present?
      reports = reports.title_like(search_params[:title])
    end

    if search_params[:updated_at].present?
      reports = reports.updated_at(search_params[:updated_at])
    end

    if search_params[:sender_name].present?
      reports = reports.sender_name_like(search_params[:sender_name])
    end

    if search_params[:keywords].present?
      reports = reports.keywords_like(search_params[:keywords])
    end

    reports
  end

  scope :title_like, ->(title) { where('title LIKE ?', "%#{title}%") }
  scope :updated_at, ->(updated_at) { where('updated_at BETWEEN ? AND ?', "#{updated_at} 00:00:00", "#{updated_at} 23:59:59") }
  scope :sender_name_like, ->(sender_name) { where('sender_name LIKE ?', "%#{sender_name}%") }
  scope :keywords_like, ->(keywords) {
    joins(:answers).where('answers.value LIKE ? OR ARRAY_TO_STRING(answers.array_value, \',\') LIKE ?', "%#{keywords}%", "%#{keywords}%")
  }

  # プロジェクトの報告集計対象のユーザーidを取得
  def self.get_aggregated_members(project)
    return project.project_users.where(member_expulsion: false).map(&:user_id)
  end

  # 報告集計対象のユーザーの任意の期間の報告を取得
  def self.get_aggregated_reports(project, period, aggregated_members)
    return project.reports.where(report_day: period, user_id: aggregated_members)
  end

  # 報告日までに報告したユーザーの数を取得
  def self.befor_deadline_reports_size(project_reports)
    if project_reports.present?
      return project_reports.map { |report| report.report_day == report.created_at.to_date ? report.user_id : nil }.compact.uniq.size
    else
      return 0
    end
  end

  # クラスメソッド: 月次レポートを取得する
  def self.monthly_reports_for(project, user, page)
    start_of_month = Time.zone.today.beginning_of_month
    end_of_month = Time.zone.today.end_of_month
    monthly_reports = project.reports.where('updated_at >= ? AND updated_at <= ?', start_of_month, end_of_month)
    if monthly_reports.present?
      reports = monthly_reports.where.not(sender_id: user.id).order(updated_at: 'DESC').page(page).per(10)
      you_reports = monthly_reports.where(sender_id: user.id).order(updated_at: 'DESC').page(page).per(10)
      { reports: reports, you_reports: you_reports }
    else
      { reports: [], you_reports: [] }
    end
  end

  # クラスメソッド: 週次レポートを取得する
  def self.weekly_reports_for(project, user, page)
    start_of_week = Time.zone.today.beginning_of_week
    end_of_week = Time.zone.today.end_of_week
    weekly_reports = project.reports.where('updated_at >= ? AND updated_at <= ?', start_of_week, end_of_week)
    if weekly_reports.present?
      reports = weekly_reports.where.not(sender_id: user.id).order(updated_at: 'DESC').page(page).per(10)
      you_reports = weekly_reports.where(sender_id: user.id).order(updated_at: 'DESC').page(page).per(10)
      { reports: reports, you_reports: you_reports }
    else
      { reports: [], you_reports: [] }
    end
  end
end
