class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :except => [:destroy]

  def new
    current_user_session.destroy unless current_user_session.blank?
    @user_session = AdminCoreSession.new
    @is_failed = params[:is_failed] || false
  end
  
  def create
    @user_session = AdminCoreSession.new(params[:admin_core_session])
    if @user_session.save
      redirect_to dashboards_path
    else
      redirect_to new_user_session_path({:is_failed=>true})
    end
  end

  def destroy
    @user_session = AdminCoreSession.find
    @user_session.destroy
    redirect_to root_url
  end

  def new_worker
    system "/usr/bin/rake resque:work QUEUE=* RAILS_ENV=production &"
    render :text=> "1 New Wroker added"
  end

end
