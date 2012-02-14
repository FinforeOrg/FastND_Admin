class ProfileCategoriesController < ApplicationController
  before_filter :before_render
  
  def index
    @profile_categories = ProfileCategory.includes(:profiles)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile_categories }
    end
  end

  # GET /profile_categories/new
  # GET /profile_categories/new.xml
  def new
    @profile_category = ProfileCategory.new

    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
      format.xml  { render :xml => @profile_category }
    end
  end

  # GET /profile_categories/1/edit
  def edit
    @profile_category = ProfileCategory.find(params[:id])
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  # POST /profile_categories
  # POST /profile_categories.xml
  def create
    @profile_category = ProfileCategory.new(params[:profile_category])

    respond_to do |format|
      if @profile_category.save
        format.html { redirect_to profile_categories_path, :notice => "#{@profile_category.title} has been created." }
        format.xml  { render :xml => @profile_category, :status => :created, :location => @profile_category }
      else
        format.html { render :action => "new", :layout=> false }
        format.xml  { render :xml => @profile_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profile_categories/1
  # PUT /profile_categories/1.xml
  def update
    @profile_category = ProfileCategory.find(params[:id])

    respond_to do |format|
      if @profile_category.update_attributes(params[:profile_category])
        format.html { redirect_to profile_categories_path, :notice => "#{@profile_category.title} has been modified." }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout=> false }
        format.xml  { render :xml => @profile_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_categories/1
  # DELETE /profile_categories/1.xml
  def destroy
    @profile_category = ProfileCategory.find(params[:id])
    @profile_category.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(profiles_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end

  private
    def before_render
      @focuses_selected = true
    end
end
