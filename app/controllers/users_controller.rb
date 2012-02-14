class UsersController < ApplicationController
  before_filter :before_render
  before_filter :prepare_profiles, :only => [:new,:create,:edit,:update]
  skip_before_filter :require_user, :only => [:columns]
  
  def index
    params[:page] = params[:page] || 1
    condition = {"$or" => [{:login => /#{params[:keyword]}/i}, {:full_name => /#{params[:keyword]}/i}]}
    conditions.merge!({:profile_ids.in => [params[:pid]]}) unless params[:pid].blank?
    includes = params[:pid].blank? ? [] : [:profiles]
    @title = Profile.find(params[:pid]).title unless params[:pid].blank?
    @users = User.search_by(params[:page],condition,includes)
    @is_content_only = params[:partial] ? true: false

    respond_to do |format|
      format.html { render :layout=> !@is_content_only}
      format.json { render :json => @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @user = User.new
    @is_populate = false
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def edit
    @user = User.find(params[:id])
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def create
    params[:user][:login] = params[:user][:email_home] = params[:user][:email_work]
    params[:user][:password] = params[:user][:password_confirmation] = generate_password if params[:user][:password].blank?
    @user = User.new(params[:user])
    @is_populate = params[:is_populate]
    respond_to do |format|
      if @user.save
        start_autopopulate if @is_populate
        send_thanks_email(params[:user][:password])
        @message = "#{@user.full_name} has been created."
	      Resque.enqueue(Finforenet::Jobs::CheckPublicProfiles, @user.id) if @user.is_public
        if !request.xhr?
          format.html { redirect_to users_path({:page=>params[:page]}), :notice => @message }
        else
          @message << "You can edit now or refresh the page."
          @user.password = @user.password_confirmation = ""
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
      else
        @user.password = @user.password_confirmation = ""
        format.html { render :action => "new", :layout=> !request.xhr? }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    if params[:user][:email_work] != @user.login
      params[:user][:login] = params[:user][:email_work]
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        @message = "#{@user.full_name} has been modified."
	      Resque.enqueue(Finforenet::Jobs::CheckPublicProfiles, @user.id) if @user.is_public
        if !request.xhr?
          format.html { redirect_to users_path({:page=>params[:page]}), :notice => @message }
        else
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
      else
        format.html { render :action => "edit", :layout=> !request.xhr? }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(users_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
    end
  end

  def columns
    @user = User.find(params[:id])
    @accounts = @user.feed_accounts
    #@account = @user.feed_accounts.build
    respond_to do |format|
      if params[:partial].blank?
        format.html { render :action => "show", :layout=> !request.xhr? }
      else
        format.html { render :layout=> !request.xhr? }
      end
    end
  end

  def company_tabs
    @user = User.find(params[:id])
    tab_condition = "company_competitors.feed_info_id IS NOT NULL"
    competitors = CompanyCompetitor.page(params[:page]||1).per(25)
    @feed_infos = Kaminari.paginate_array(competitors.map{|c| c.feed_info}).page(params[:page]||1).per(25)
    @tabs = @user.user_company_tabs if params[:page].blank?
    respond_to do |format|
      if params[:partial].blank? && params[:page].blank?
        format.html { render :action => "show", :layout=> !request.xhr? }        
      elsif params[:page]
        format.html { render :layout=> !request.xhr? }
      end
    end
  #rescue => e
   # respond_to do |format|
    #  format.html {render :text => e.to_s}
    #end
  end

  def autocomplete
    condition = {"$or" => [{:login => /#{params[:q]}/i}, {:full_name => /#{params[:q]}/i}]}
    @users = User.where(condition).limit(params[:limit]).asc(:full_name)
    results = @users.map{|u| "#{u.full_name}|#{u.id}\n"}.join("")
    respond_to do |format|
      format.html {render :text=> results}
    end
  end

  def update_public
    user = User.find params[:id]
    if user
      status = user.is_public ? false : true
      user.update_attribute(:is_public,status)
    end
    respond_to do |format|
      format.html {render :text => "SUCCESS"}
    end
  end

  def count_focuses
    user = User.where(:_id => params[:uid]).first
    render :text => user ? user.profiles.count : ""
  end

  private
    def before_render
      @users_selected = true
    end

    def prepare_profiles
      @categories = ProfileCategory.includes(:profiles).where({"profiles.is_private" => {"$ne" => true}})
    end

    def send_thanks_email(password)
      UserMailer.deliver_welcome_email(@user,password)
      UserMailer.deliver_new_user_to_admin(@user)
    end

    def start_autopopulate
      @user.create_autopopulate
    end

end
