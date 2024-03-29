class BaseController < ApplicationController
  # before_action :authenticate_user!

  # 報告、連絡、相談の一覧を選択されたプロジェクトによって切り替える
  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def index_switching
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    case params[:list_type]
    when 'report'
      @first_question = @project.questions.first
      @report_label_name = @first_question.send(@first_question.form_table_type).label_name
      @reports = @project.reports.where.not(user_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(5)
      @you_reports = @project.reports.where(user_id: @user.id).order(created_at: 'DESC').page(params[:page]).per(5)
    when 'message'
      @messages = @project.messages.all.order(created_at: 'DESC').page(params[:page]).per(5)
      you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
      @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(created_at: 'DESC').page(params[:page]).per(5)
    when 'counseling'
      @counselings = @project.counselings.all.order(created_at: 'DESC').page(params[:page]).per(5)
      you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
      @you_addressee_counselings = @project.counselings.where(id: you_addressee_counseling_ids).order(created_at: 'DESC').page(params[:page]).per(5)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # プロジェクトリーダーを許可
  def project_leader_user
    @project = if params[:project_id].present?
                 Project.find(params[:project_id])
               else
                 Project.find(params[:id])
               end

    return if current_user.id == @project.leader_id

    flash[:danger] = t('flash.not_leader')
    redirect_to user_project_path(current_user, @project)
  end
end
