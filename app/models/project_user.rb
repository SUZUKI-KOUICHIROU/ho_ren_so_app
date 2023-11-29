class ProjectUser < ApplicationRecord
  belongs_to :user
  belongs_to :project

  # プロジェクトメンバーそれぞれに報告集計メンバーの除外ステータスを追加する
  def self.member_expulsion_join(project, members)
    project_member_expulsions = project.project_users.all
    members.each do |member|
      member.member_expulsion = project_member_expulsions.find_by(user_id: member.id).member_expulsion
    end
    return members
  end

  # 報告リマインダーに対し、選択時刻で設定を行うメソッド
  def set_report_reminder_time(report_time)
    # report_timeをTime型に変換
    report_time = Time.zone.parse(report_time)
    # タイムゾーンをJSTに変換
    self.report_reminder_time = report_time.in_time_zone('Asia/Tokyo')

    save!
     # reminder_time が返されるよう設定
    self.report_reminder_time
  end

  # キューにリマインドジョブを追加するメソッド
  def queue_report_reminder(project_id, member_id, report_time)
    # set_report_reminder_time を使って report_reminder_time を設定
    set_report_reminder_time(report_time)

    # 報告リマインド時刻が未来の日時かどうかを確認
    if self.report_reminder_time.present?
      # 指定時刻が過去の場合、翌日の同時刻に更新
      self.report_reminder_time += 1.day if self.report_reminder_time < Time.current

      # 1度目のメール送信ジョブをキューに追加（JST時刻）
      ReminderJob.set(wait_until: self.report_reminder_time).perform_later(project_id, member_id, report_time)

      # 翌日以降～1ヶ月間、継続して同じ指定時刻に送信するよう、次回のジョブをキューに追加（JST時刻）
      next_reminder_time = self.report_reminder_time + 1.day
      while next_reminder_time < 1.month.from_now
        ReminderJob.set(wait_until: next_reminder_time).perform_later(project_id, member_id, report_time)
        next_reminder_time += 1.day
      end
    else
      Rails.logger.warn "Invalid report_reminder_time: #{self.report_reminder_time}. #{error_message}"
    end
  end
end
