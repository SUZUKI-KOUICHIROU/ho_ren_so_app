class Projects::ReportsController < Projects::BaseProjectController

  def index
    set_project_and_members
    @first_question = @project.questions.first
    @report_label_name = @first_question.send(@first_question.form_table_type).label_name
    @reports = @project.reports.where.not(sender_id: @user.id).order(updated_at: 'DESC').page(params[:page]).per(10)
    @you_reports = @project.reports.where(sender_id: @user.id).order(updated_at: 'DESC').page(params[:page]).per(10)
    if params[:search].present? and params[:search] != ""
      @results = Answer.where('value LIKE ?', "%#{params[:search]}%")
      if @results.present?
        @report_ids = @results.map { |r| r[:report_id] }.uniq
      else
        @report_ids = 0
      end
      @reports = @project.reports.where.not(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @project.reports.where(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
    end
  end

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
    @answer = @report.answers.build
    @questions = @project.questions.where(using_flag: true)
  end

  def create
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = @project.reports.new(create_reports_params)
    @report.sender_id = @user.id
    @report.sender_name = @user.user_name
    if @report.save
      flash[:success] = '報告を登録しました。'
    else
      flash[:danger] = '報告の登録に失敗しました。'
    end
    @report.save
    @project.report_statuses.find_by(user_id: @user.id, is_newest: true).update(has_submitted: true)
    flash[:success] = "報告を登録しました。"
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def edit
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end

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
          answer.update(value: params[:answer][cnt_num][:value])
        when 'text_area'
          answer.update(value: params[:answer][cnt_num][:value])
        when 'radio_button'
          if params[:answer][cnt_num].nil?
            answer.update(value: "")
          else
            answer.update(value: params[:answer][cnt_num][:value]) 
          end
        when 'check_box'
          answer.update(array_value: params[:answer][cnt_num])
        when 'select'
          answer.update(value: params[:answer][cnt_num][:value])
        end
      end
      cnt += 1
    end
    if @report.remanded
      @report.update(remanded: false)
      NotificationMailer.send_fix_notification(@user).deliver_now
    elsif !@report.remanded
      @report.update(remanded: false)
    end
    flash[:success] = "報告を編集しました。"
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def destroy
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    if @report.destroy
      flash[:success] = "報告を削除しました。"
    else
      flash[:danger] = "報告の削除に失敗しました。"
    end
    redirect_to user_project_reports_path(@user,@project)
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
    else
      flash[:danger] = "登録に失敗しました。"
    end
    redirect_to action: :show
  end

  def view_reports
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @reports = @project.reports.where(report_day: @project.report_deadlines.last.day).where(remanded: false).page(params[:reports_page]).per(10)
    report_users_id = []
    i = 0
    report_users = @project.reports.where(report_day: @project.report_deadlines.last.day).where(remanded: false).select(:user_id).distinct
    report_users.each do |user|
      report_users_id[i] = user.user_id
      i += 1
    end
    @report_users = @project.users.all.where(id: report_users_id).page(params[:report_users_page]).per(10)
    @not_report_users = @project.users.all.where.not(id: report_users_id).page(params[:not_report_users_page]).per(10)
  end

  def view_reports_log
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @display = params[:display].nil??
    "percent" : params[:display]
    @first_day = params[:date].blank??
    Date.current.beginning_of_month : Date.strptime(params[:date], '%Y-%m')
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    @report_days = @project.report_deadlines.order(id: "DESC").where(day: @first_day..@last_day)
    @month_field_value = @first_day.strftime("%Y-%m")
    if params[:search].present? and params[:search] != ""
      @results = Answer.where('value LIKE ?', "%#{params[:search]}%")
      if @results.present?
        @report_ids = @results.map { |r| r[:report_id] }.uniq
      else
        @report_ids = 0
      end
      @reports = @project.reports.where.not(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
      @you_reports = @project.reports.where(sender_id: @user.id).where(id: @report_ids).order(updated_at: 'DESC').page(params[:page]).per(10)
    end
    
  end

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
      ]
    )
  end
end
