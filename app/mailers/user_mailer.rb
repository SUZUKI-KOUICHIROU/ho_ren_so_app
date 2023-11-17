class UserMailer < ApplicationMailer
  def invitation(user, token, name, password)
    @user = user
    @inviter = User.find(@user.invited_by).name
    @token = token
    @project_name = name
    @password = password
    mail to: @user.email, subject: "【ホウレンソウアプリ】プロジェクトへの招待のお知らせ"
  end

  # プロジェクト内の未報告メンバーをリーダーに報告
  def notice_not_submitted_members(_project_name, users, to_address)
    @project_name = name
    @users = users
    mail to: to_address, subject: "#{name}未報告者のご連絡"
  end

  # 未報告メンバーにリマインドメールを送信
  def send_remind(name, to_address)
    @project = name
    mail to: to_address, subject: "【リマインド】#{name}の報告期限が迫っています。"
  end

  # 報告リマインドメールを送信する処理（パターン➃）
  def reminder_email(user_id, report_time, project_id)
    @user = User.find(user_id)
    @report_time = report_time
    @project_name = Project.find(project_id).name
    mail(to: @user.email, subject: '報告リマインド')
  end
end
