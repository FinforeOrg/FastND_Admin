class UserFeedsController < ApplicationController
  before_filter :prepare_user
  before_filter :prepare_feed_account
  # GET /user_feeds
  # GET /user_feeds.xml
  def index
    @user_feeds = @feed_account.user_feeds
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_feeds }
    end
  end

  # GET /user_feeds/1
  # GET /user_feeds/1.xml
  def show
    @user_feed = @feed_account.user_feeds.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_feed }
    end
  end

  # GET /user_feeds/new
  # GET /user_feeds/new.xml
  def new
    @user_feed = UserFeed.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_feed }
    end
  end

  # GET /user_feeds/1/edit
  def edit
    @user_feed = @feed_account.user_feeds.find(params[:id])
  end

  # POST /user_feeds
  # POST /user_feeds.xml
  def create
    if params[:feed_info] && params[:feed_info][:ids].size > 0
      params[:feed_info][:ids].each do |id|
        if @feed_account.user_feeds.where(:feed_info_id => id).first.nil?
          @feed_account.user_feeds.create({:title => "", :feed_info_id => id})
        end
      end
      @feed_account = FeedAccount.find(params[:feed_account_id],:include=>:user_feeds,:select=>"feed_accounts.id,user_feeds.id")
    elsif params[:user_feed]
      @user_feed = @feed_account.user_feeds.build(params[:user_feed])
    end

    respond_to do |format|
      if params[:user_feed] && @user_feed.save
        format.html { redirect_to(@user_feed, :notice => 'UserFeed was successfully created.') }
        format.xml  { render :xml => @user_feed, :status => :created, :location => @user_feed }
      elsif @feed_account
        format.html { render :partial => "feed_accounts/column_feeds",:layout=>false}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_feeds/1
  # PUT /user_feeds/1.xml
  def update
    @user_feed = @feed_account.user_feeds.find(params[:id])

    respond_to do |format|
      if @user_feed.update_attributes(params[:user_feed])
        format.html { redirect_to(@user_feed, :notice => 'UserFeed was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_feeds/1
  # DELETE /user_feeds/1.xml
  def destroy
    @user_feed = @feed_account.user_feeds.find(params[:id])
    @user_feed.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(user_feeds_url) }
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

    def prepare_feed_account
      @feed_account = @user.feed_accounts.find(params[:feed_account_id])
    end

end
