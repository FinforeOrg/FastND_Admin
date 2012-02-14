class FeedAccountsController < ApplicationController
  include Finforenet::Controllers::SocialNetwork
  skip_before_filter :require_user, :only => [:column_callback]
  before_filter :prepare_user
  before_filter :prepare_feed_account, :only => [:edit, :update, :destroy]
  before_filter :prepare_followers
  
  def new
    @feed_account = @user.feed_accounts.build({:window_type => "tab", :category => params[:category].to_s.gsub("search","keyword")})
    @feed_account.build_keyword_column if @feed_account.hasAggregate?

    respond_to do |format|
      if @feed_account.category.blank?
        format.html { render :layout=> !request.xhr?}
      else
        format.html { render :action=>:edit, :layout=> !request.xhr?}
      end
      format.xml  { render :xml => @feed_account }
    end
  end

  def edit
    prepare_suggestions if @feed_account
    respond_to do |format|
      if params[:page].blank? || !request.xhr?
        format.html { render :layout=> !request.xhr?}
      else
        format.html { render :partial=> "finfore_suggestion", :layout=> !request.xhr?}
      end
    end
  end

  def create
    @feed_account = @user.feed_accounts.create(params[:feed_account])
    
    respond_to do |format|
      if @feed_account.errors.any?
        @messsage = "#{@feed_account.name} column was successfully created."
        if !request.xhr?
          format.html { render :action =>"edit",:layout=> !request.xhr?,:notice => @message}
        else
          format.html { render :text=> "CREATED" }
        end
        format.xml  { render :xml => @feed_account, :status => :created, :location => @feed_account }
      else
        format.html { render :action => "edit",:layout=> !request.xhr? }
        format.xml  { render :xml => @feed_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @feed_account.update_attributes(params[:feed_account])
        @message = "#{@feed_account.name} has been modified."
        if !request.xhr?
          format.html { redirect_to columns_user_url({:id=>@user.id}), :notice => @message }
        else
          format.html { render :text=> "SUCCESS" }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed_account.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feed_account.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(columns_user_url({:id=>@user.id})) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end

  def column_auth
    user = User.find params[:user_id]
    if user
      auth_domain = request.host.match(/admin/i) ? "http://live.fastnd.com/" : "http://api.fastnd.com/"
      auth_url = "#{auth_domain}users/#{user.id}/feed_accounts/#{params[:provider].downcase}/auth?auth_token=#{user.single_access_token}"
      auth_url = auth_url+"&feed_account_id=#{params[:feed_account_id]}" unless params[:feed_account_id].blank?
      callback = auth_domain
      callback = callback + "users/#{user.id}/columns"
      auth_url = auth_url + "&callback=#{callback}"
    end

    if auth_url.blank?
      render :text=>get_failed_message
    else
      redirect_to auth_url
    end
  end

  def column_callback
    respond_to do |format|
      format.html {redirect_to users_url}
    end
  end

  private
    def prepare_user
      @user = User.find(params[:user_id])
    end
    
    def prepare_feed_account
      @feed_account = @user.feed_accounts.find(params[:id])
    end
    
    def prepare_suggestions
      @feed_infos = []
      @category = @feed_account.category
      @show_all = false
      @conditions = FeedInfo.send("#{@category}_query")
      @conditions = FeedInfo.profiles_query(@user,@conditions) if profileable?
      prepare_list_for_user
    end
    
    def profileable?
      @user && !@show_all && !is_chart
    end

    def prepare_list_for_user
      if !is_chart_or_all_companies
        @feed_infos = FeedInfo.filter_feeds_data(@conditions,(params[:per_page]||25), params[:page]||1)
		    sanitize_feed_info_profile unless @show_all
      elsif is_all_companies
        #@feed_infos = FeedInfo.all_with_competitor(@conditions)
         @feed_infos = Kaminari.paginate_array(CompanyCompetitor.all.map(&:feed_info)).page(params[:page]).per(params[:per_page])
      elsif is_chart
        @feed_infos = Kaminari.paginate_array(FeedInfo.all_sort_title(@conditions)).page(params[:page]).per(params[:per_page])
      else
       @feed_infos = Kaminari.paginate_array(@feed_infos).page(params[:page]||1).per(25)
      end
      #feed_info_complain(@category) if @feed_infos.size < 1
    end

    def sanitize_feed_info_profile
      if @user
        pids = @user.profiles.map(&:id)
        _garbage = []
        @feed_infos.each do |_info|
	       return unless _info.class.equal?(FeedInfo)
           _info_profiles = _info.profiles.map(&:id)
	         _expected_remain = _info_profiles.size - pids.size
           _remain = _info_profiles - pids          
           @feed_infos = @feed_infos - [_info] if _remain.size != _expected_remain
        end
        @feed_infos = Kaminari.paginate_array(@feed_infos).page(params[:page]||1).per(25)
      end
    end  

    def is_show_all
      _return = false
      @category = params[:category].downcase
      if @category =~ /all/i    
        @category = @category.gsub(/all|\,/i,"")
        @category = "all_companies" if @category =~ /_companies|_company/i
        _return = true
      end
      return _return
    end

    def price_conditions
      chart_conditions
    end 
    
    def is_chart
      return @category.match(/chart|price/i)
    end
    
    def is_chart_or_all_companies
      return (is_chart || is_all_companies)
    end
    
    def is_all_companies
      return @category.match(/all_companies/i)
    end

    def create_column_and_token(access_token,api,stored_data,user)
      profile = get_profile_network(access_token,api,stored_data)
      acct = FeedAccount.create({:name => (stored_data[:category] != "linkedin" ? profile['uid'] : profile['name']), 
                                 :account  => profile['uid'],
                                 :category => stored_data[:category],
                                 :user_id => user.id,
                                 :window_type => 'tab'})
      ft = FeedToken.create({:user_id => user.id, :feed_account_id => acct.id,
                             :token  => (stored_data[:category] == "facebook" ? access_token['access_token'] : access_token.token),
                             :secret => (stored_data[:category] == "facebook" ? '' : access_token.token)}) if acct
      return acct
    end
end
