class Projects::ReportsController < Projects::BaseProjectController
  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def index
    set_project_and_members
    @first_question = @project.questions.first
    @report_label_name = @first_question.send(@first_question.form_table_type).label_name
    @reports = @project.reports.where.not(sender_id: @user.id).order(updated_at: 'DESC').page(params[:page]).per(10)
    @you_reports = @project.reports.where(sender_id: @user.id).order(updated_at: 'DESC').page(params[:page]).per(10)
    if params[:search].present? and params[:search] != ""
      @results = Answer.where('value LIKE ?', "%#{params[:search]}%")
      if @results.present?
        @report_ids = @results.pluck(:report_id).uniq
      else
        @report_ids = 0
      end
      @reports = @project.reports.where.not(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @project.reports.where(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    set_project_and_members
    @user = User.find(params[:user_id])
    @report = Report.find(params[:id])
    @answers = @report.answers
  end

  def new
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects
    @report = @user.reports.build(project_id: @project.id)
    @answer = @report.answers.new
    @questions = @project.questions.where(using_flag: true)
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def create
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = @project.reports.new(create_reports_params)
    @report.sender_id = @user.id
    @report.sender_name = @user.name
    @report.answers.each do |answer|
      answer.question_name = answer.question_type.camelize.constantize.find_by(question_id: answer.question_id).label_name
    end
    if @report.save
      flash[:success] = '報告を登録しました。'
    else
      flash[:danger] = '報告の登録に失敗しました。'
    end
    @project.report_statuses.find_by(user_id: @user.id, is_newest: true).update(has_submitted: true)
    flash[:success] = "報告を登録しました。"
    redirect_to user_project_report_path(@user, @project, @report)
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
  def update
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.find(params[:id])
    @report.title = params[:title]
    @answers = @report.answers
    cnt = 1
    @answers.each do |answer|
      cnt_num = "#{cnt}"
      if params[:answer]
        case answer.question_type
        when 'text_field'
          if TextField.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            answer.update(value: params[:answer][cnt_num][:value])
          end
        when 'text_area'
          if TextArea.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            answer.update(value: params[:answer][cnt_num][:value])
          end
        when 'date_field'
          if DateField.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            answer.update(value: params[:answer][cnt_num][:value])
          end
        when 'radio_button'
          if RadioButton.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            if params[:answer][cnt_num].nil?
              answer.update(value: "")
            else
              answer.update(value: params[:answer][cnt_num][:value])
            end
          end
        when 'check_box'
          if CheckBox.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            answer.update(array_value: params[:answer][cnt_num])
          end
        when 'select'
          if Select.find_by(question_id: answer.question_id).nil?
            answer.destroy
          else
            answer.update(value: params[:answer][cnt_num][:value])
          end
        end
      end
      cnt += 1
    end
    @report.update(resubmitted: params[:resubmitted])
    flash[:success] = "報告を編集しました。"
    redirect_to user_project_report_path(@user, @project, @report)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

  def destroy
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    if @report.destroy
      flash[:success] = "報告を削除しました。"
    else
      flash[:danger] = "報告の削除に失敗しました。"
    end
    redirect_to user_project_reports_path(@user, @project)
  end

  # 全プロジェクト報告集計画面表示
  def all_project_reporting_rate
    @user = current_user
    @report_days_for_each_four_weeks = four_weeks_from_yesterday_array
    # プロジェクトの情報とそのプロジェクトの報告率の値を持つ配列を代入
    @projects = Project.all.map do |project|
      @four_weeks_report_rate_array = []
      @n = 5
      # プロジェクトの一週間の報告率を４週間分のハッシュの配列として代入
      report_rate_for_each_four_weeks = @report_days_for_each_four_weeks.map do |one_week|
        @n -= 1
        one_week_reports_rate = one_week_report_rate_calc(one_week, project)
        @four_weeks_report_rate_array = @four_weeks_report_rate_array.push(one_week_reports_rate)
        ["rate_week#{@n}".to_sym, "#{one_week_reports_rate}%"]
      end
      overall_reporting_rate_array = [[:overall_reporting_rate, "#{overall_report_rate_calc(@four_weeks_report_rate_array)}%"]]
      link_status = project_mender_or_admin?(@user, project)
      project_date_array = [[:project_name, project.name], [:id, project.id], [:created_at, project.created_at], [:link_on, link_status]]
      project_array = report_rate_for_each_four_weeks + project_date_array + overall_reporting_rate_array
      project_array.to_h
    end
  end

  # 再提出を求める。
  def reject
    @report = Report.find(params[:id])
    @user = current_user
    if params[:report][:remanded_reason] != ""
      @report.update!(params.require(:report).permit(:remanded_reason, :remanded))
      if @report.save
        flash[:success] = "登録完了しました。"
        NotificationMailer.send_rework_notification(@user).deliver_now
      else
        flash[:danger] = "登録に失敗しました。"
      end
    elsif params[:report][:remanded_reason] == ""
      if @report.update!(remanded: false, remanded_reason: nil)
        flash[:success] = "登録に完了しました。"
      else
        flash[:danger] = "登録に失敗しました。"
      end
    end
    redirect_to action: :show
  end

  # 再提出の承認
  def resubmitted
    @report = Report.find(params[:id])
    if @report.update(params.require(:report).permit(:remanded, :resubmitted))
      if @report.update(remanded_reason: nil)
        flash[:success] = "報告手直しを承認しました。"
      end
    else
      flash[:danger] = "登録に失敗しました。"
    end
    redirect_to action: :show
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def view_reports
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @reports = @project.reports.where(report_day: @project.report_deadlines.last.day).where(remanded: false).page(params[:reports_page]).per(10)
    reported_users_id = []
    i = 0
    reported_users = @project.reports.where(report_day: @project.report_deadlines.last.day).where(remanded: false).select(:user_id).distinct
    reported_users.each do |user|
      reported_users_id[i] = user.user_id
      i += 1
    end
    @reported_users = @project.users.all.where(id: reported_users_id).page(params[:reported_users_page]).per(10)
    @unreported_users = @project.users.all.where.not(id: reported_users_id).page(params[:unreported_users_page]).per(10)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def view_reports_log
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @display = params[:display].nil? ?
    "percent" : params[:display]
    @first_day = params[:date].blank? ?
    Date.current.beginning_of_month : Date.strptime(params[:date], '%Y-%m')
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    @report_days = @project.report_deadlines.order(id: "DESC").where(day: @first_day..@last_day)
    @month_field_value = @first_day.strftime("%Y-%m")
    if params[:search].present? and params[:search] != ""
      @results = Answer.where('value LIKE ?', "%#{params[:search]}%")
      if @results.present?
        @report_ids = @results.pluck(:report_id).uniq
      else
        @report_ids = 0
      end
      @reports = @project.reports.where.not(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @project.reports.where(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def report_form_switching
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects
    @report = @user.reports.build(project_id: @project.id)
    @answer = @report.answers.build
    @questions = @project.questions.where(using_flag: true)
  end

  private

  # フォーム新規登録並びに編集用/create
  def create_reports_params
    params.require(:report).permit(:id, :user_id, :project_id, :title, :report_day,
      answers_attributes: [
        :id, :question_type, :question_id, :value, array_value: []
      ])
  end

  # 報告日のみの検索に使用するパラメーター
  def search_params
    params.permit(:search)
  end

  # 昨日もしくは、送られた最終報告集計日から４週間を一週間ごとに配列に代入
  def four_weeks_from_yesterday_array
    four_weeks_last_rate_day = if search_params[:search].present?
                                 search_params[:search].to_date
                               else
                                 Date.yesterday
                               end
    one_week_last_rate_day = four_weeks_last_rate_day
    one_week_first_rate_day = four_weeks_last_rate_day - 6
    return (1..4).map do |n|
      if n == 1
        one_week_first_rate_day..one_week_last_rate_day
      elsif n > 1
        n_week_ago = (n - 1)
        n_week_ago.weeks.before(one_week_first_rate_day)..n_week_ago.weeks.before(one_week_last_rate_day)
      end
    end
  end

  # プロジェクトメンバー全員の一週間の報告率を計算して返す
  def one_week_report_rate_calc(one_week, project)
    project_four_weeks_reports_size = Report.befor_deadline_reports_size(project.reports.where(report_day: one_week))
    return (project_four_weeks_reports_size.quo(7 * project.project_users.size).to_f * 100).floor
  end

  # プロジェクトメンバーかスタッフかを判断する
  def project_mender_or_admin?(user, project)
    if user.project_users.find_by(project_id: project.id).present? || user.admin
      return true
    else
      return false
    end
  end

  # 総合報告率の計算
  def overall_report_rate_calc(reports_rate_array)
    return reports_rate_array.sum.quo(reports_rate_array.size).to_f.floor
  end
end
