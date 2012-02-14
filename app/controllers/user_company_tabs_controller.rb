class UserCompanyTabsController < ApplicationController
  before_filter :prepare_followers, :only =>[:edit,:update]
  before_filter :prepare_user
  before_filter :prepare_company_tab, :except => [:index,:new,:create]

  def index
    @user_company_tabs = UserCompanyTab.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_company_tabs }
    end
  end

  # GET /user_company_tabs/1
  # GET /user_company_tabs/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_company_tab }
    end
  end

  # GET /user_company_tabs/new
  # GET /user_company_tabs/new.xml
  def new
    @user_company_tab = @user.user_company_tabs.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_company_tab }
    end
  end

  # GET /user_company_tabs/1/edit
  def edit
    @feed_info = @user_company_tab.feed_info
    respond_to do |format|
      format.html {render :layout=>!request.xhr?}
    end
  end

  # POST /user_company_tabs
  # POST /user_company_tabs.xml
  def create
    if params[:feed_info] && params[:feed_info][:ids].size > 0
      params[:feed_info][:ids].each do |id|
        company_tab = @user.user_company_tabs.where(:feed_info_id => id).first
        unless company_tab
          @user.user_company_tabs.create({:feed_info_id => id, :follower => 100, :is_aggregate => true})
        end
      end
      @tabs = @user.user_company_tabs
    elsif params[:user_company_tab]
      @user_company_tab = @user.user_company_tabs.create(params[:user_company_tab])
    end

    respond_to do |format|
      if params[:user_company_tab] && @user_company_tab.errors.any?
        format.html { redirect_to company_tabs_user_path(@user_company_tab.user), :notice => 'User Company Tab was successfully created.' }
      elsif @tabs
        format.html { render :partial => "feed_accounts/column_feeds",:layout=>false}
      else
        format.html { render :action => "new",:layout=>!request.xhr?}
      end
    end
  end

  # PUT /user_company_tabs/1
  # PUT /user_company_tabs/1.xml
  def update
    @feed_info = @user_company_tab.feed_info
    respond_to do |format|
      if @user_company_tab.update_attributes(params[:user_company_tab])
        @message = "#{@user_company_tab.feed_info.title} has been modified for #{@user_company_tab.user.full_name}."
        if !request.xhr?
          format.html { redirect_to company_tabs_user_path(@user_company_tab.user), :notice => @message }
        else
          format.html { render :action => "edit",:layout=>!request.xhr? }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit",:layout=>!request.xhr? }
        format.xml  { render :xml => @user_company_tab.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_company_tabs/1
  # DELETE /user_company_tabs/1.xml
  def destroy
    @user_company_tab.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(company_tabs_user_path(@user_company_tab.user)) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end
  
  private
    def prepare_user
      @user = User.find(params[:user_id])
    end
    
    def prepare_company_tab
      @user_company_tab = @user.user_company_tabs.find(params[:id])
    end
  
end
