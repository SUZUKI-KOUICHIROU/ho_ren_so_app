class Users::InvitationsController < BaseController
  #before_action :get_user,         only: [:edit, :update]
  #before_action :valid_user,       only: [:edit, :update]
  #before_action :check_expiration, only: [:edit, :update]

  def new
    @user = User.find(current_user.id)
    @project = Project.find(params[:project_id])
    #@project.users << current_user
    #redirect_to root_path
  end

  def create
    @project = Project.find(params[:project_id])
    if params[:invitee][:email].blank?
      flash[:danger] = 'メールアドレスを入力してください。'
      render 'new'
    else
      @user_id = params[:user_id]
      @user = User.create(user_name: "名無しの招待者", email: params[:invitee][:email].downcase, invited_by: current_user.id)
      #@user.create_invite_digest
      #user.projects << project
      @user.send_invite_email
      flash[:info] = '招待メールを送信しました！'
      redirect_to root_url
    end
  end

  def edit
    @user.name = nil if @user
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.activate
      log_in @user
      inviter = User.find(@user.invited_by)
      @user.follow(inviter)
      inviter.follow(@user)
      flash[:success] = 'ようこそ01Booksへ!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  # beforeフィルタ

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    unless @user && !@user.activated? &&
           @user.authenticated?(:invite, params[:id]) # params[:id]はメールアドレスに仕込まれたトークン
      flash[:danger] = '無効なリンクです。'
      redirect_to root_url
    end
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.invitation_expired?
      flash[:danger] = '招待メールの有効期限が切れています。'
      redirect_to root_url
    end
  end
end
