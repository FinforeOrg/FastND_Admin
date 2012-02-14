class ProfilesController < ApplicationController
  before_filter :before_render
  before_filter :prepare_categories, :only => [:new,:edit,:update,:create]
  
  def index
    if params[:pc_id]
      params[:page] = params[:page] || 1
      @category = ProfileCategory.find(params[:pc_id])
      @profiles = @category.profiles.page(params[:page]).per(25)
    end
    respond_to do |format|
      if @profiles
        format.html # index.html.erb
        format.xml  { render :xml => @profiles }
      else
        format.html {redirect_to profile_categories_path}
      end
    end
  end

  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  def new
    @profile = Profile.new

    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
      format.xml  { render :xml => @profile }
    end
  end

  def edit
    @profile = Profile.find(params[:id])
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  def create
    @profile = Profile.new(params[:profile])
    @is_success = false
    respond_to do |format|
      if @profile.save
        if !request.xhr?
          format.html { redirect_to profiles_path({:page=>params[:page],:pc_id=>params[:pc_id]}), :notice => "#{@profile.title} has been created." }
        else
          @is_success = true
          format.html { render :action => "edit", :layout=> !request.xhr?,:notice => "#{@profile.title} has been created."}
        end
      else
        format.html { render :action => "new", :layout=> !request.xhr? }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find(params[:id])
    @is_success = false

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        if !request.xhr?
          format.html { redirect_to profiles_path({:page=>params[:page],:pc_id=>params[:pc_id]}), :notice => "#{@profile.title} has been modified." }
        else
          @is_success = true
          format.html { render :action => "edit", :layout=> !request.xhr?,:notice => "#{@profile.title} has been modified."}
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout=> !request.xhr?,:notice => "#{@profile.title} has been modified." }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(profiles_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end

  def count_suggestions
    total = FeedInfo.where(:profile_ids.in => [params[:pid]]).count
    respond_to do |format|
      format.html { render :text => total }
    end
  end

  def count_users
    total = User.where(:profile_ids.in => [params[:pid]]).count
    respond_to do |format|
      format.html { render :text => total }
    end
  end

  def count_populates
    total = FeedInfo.where({:profile_ids.in => [params[:pid]], :is_populate => true}).count
    respond_to do |format|
      format.html { render :text => total }
    end
  end

  private
    def before_render
      @focuses_selected = true
    end

    def prepare_categories
      @categories = ProfileCategory.all
    end
end
