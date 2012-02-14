class CompanyCompetitorsController < ApplicationController
    before_filter :before_render
    before_filter :prepare_tags, :only=>[:create,:edit,:new,:update,:index,:search]

  def index
    prepare_list
    @is_content_only = params[:partial] ? true: false
    respond_to do |format|
      format.html { render :layout=> !@is_content_only}
      format.xml  { render :xml => @company_competitors }
    end
  end

  # GET /company_competitors/1
  # GET /company_competitors/1.xml
  def show
    @company_competitor = CompanyCompetitor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company_competitor }
    end
  end

  # GET /company_competitors/new
  # GET /company_competitors/new.xml
  def new
    @company_competitor = CompanyCompetitor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company_competitor }
    end
  end

  # GET /company_competitors/1/edit
  def edit
    @company_competitor = CompanyCompetitor.find(params[:id])
    @feed_info = @company_competitor.feed_info
    respond_to do |format|
      format.html { render :layout=> !request.xhr?}
    end
  end

  # POST /company_competitors
  # POST /company_competitors.xml
  def create
    @company_competitor = CompanyCompetitor.new(params[:company_competitor])

    respond_to do |format|
      if @company_competitor.save
        format.html { redirect_to(@company_competitor, :notice => 'CompanyCompetitor was successfully created.') }
        format.xml  { render :xml => @company_competitor, :status => :created, :location => @company_competitor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @company_competitor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /company_competitors/1
  # PUT /company_competitors/1.xml
  def update
    @company_competitor = CompanyCompetitor.find(params[:id])
    @feed_info = @company_competitor.feed_info
    respond_to do |format|
      if @company_competitor.update_attributes(params[:company_competitor])
         @message = "#{@feed_info.title} has been modified."
        if !request.xhr?
          format.html { redirect_to company_competitors_path({:page=>params[:page]}), :notice => @message }
        else
          format.html { render :action => "edit", :layout=> !request.xhr?}
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout=> !request.xhr?}
        format.xml  { render :xml => @company_competitor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /company_competitors/1
  # DELETE /company_competitors/1.xml
  def destroy
    @company_competitor = CompanyCompetitor.find(params[:id])
    @company_competitor.destroy

    respond_to do |format|
      if !request.xhr?
        format.html { redirect_to(company_competitors_url) }
      else
        format.html { render :text=> "SUCCESS" }
      end
      format.xml  { head :ok }
    end
  end

 private
    def before_render
      @company_tabs_selected = true
    end

    def prepare_tags
      @profile_categories = ProfileCategory.includes(:profiles).asc(:title)
    end
    
    def is_on_keyword(feed_info, keyword)
      feed_info.title =~ /#{keyword}/i || feed_info.address =~ /#{keyword}/i
    end

    def prepare_list
      params[:page] = params[:page] || 1
      
      if !params[:Search].blank?
        conditions = {"$or" => [{:title => /#{params[:keyword]}/i}, {:address => /#{params[:keyword]}/i}]}
        
        if !params[:profile_ids].blank? && params[:profile_ids].size > 0
          conditions.merge!({:profile_ids.in => params[:profile_ids]})
        end
      elsif params[:pid]
        conditions.merge!({:profile_ids.in => params[:profile_ids]})
      end
      
      if conditions
        feed_infos = FeedInfo.includes(:company_competitor).asc(:title).where(conditions).select{|fi| fi.company_competitor }
        @tabs = Kaminari.paginate_array(feed_infos.map{|fi| fi.company_competitor}).page(params[:page]).per(10)
      else
        @tabs = CompanyCompetitor.page(params[:page]).per(25)
      end
    end
end
