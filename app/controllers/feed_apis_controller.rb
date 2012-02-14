class FeedApisController < ApplicationController
  # GET /feed_apis
  # GET /feed_apis.xml
  def index
    @feed_apis = FeedApi.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feed_apis }
    end
  end

  # GET /feed_apis/1
  # GET /feed_apis/1.xml
  def show
    @feed_api = FeedApi.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed_api }
    end
  end

  # GET /feed_apis/new
  # GET /feed_apis/new.xml
  def new
    @feed_api = FeedApi.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed_api }
    end
  end

  # GET /feed_apis/1/edit
  def edit
    @feed_api = FeedApi.find(params[:id])
  end

  # POST /feed_apis
  # POST /feed_apis.xml
  def create
    @feed_api = FeedApi.new(params[:feed_api])

    respond_to do |format|
      if @feed_api.save
        format.html { redirect_to(@feed_api, :notice => 'FeedApi was successfully created.') }
        format.xml  { render :xml => @feed_api, :status => :created, :location => @feed_api }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed_api.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feed_apis/1
  # PUT /feed_apis/1.xml
  def update
    @feed_api = FeedApi.find(params[:id])

    respond_to do |format|
      if @feed_api.update_attributes(params[:feed_api])
        format.html { redirect_to(@feed_api, :notice => 'FeedApi was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed_api.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_apis/1
  # DELETE /feed_apis/1.xml
  def destroy
    @feed_api = FeedApi.find(params[:id])
    @feed_api.destroy

    respond_to do |format|
      format.html { redirect_to(feed_apis_url) }
      format.xml  { head :ok }
    end
  end
end
