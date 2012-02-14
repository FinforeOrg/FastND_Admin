class UserColumnsController < ApplicationController
  # GET /user_columns
  # GET /user_columns.xml
  def index
    @user_columns = UserColumn.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_columns }
    end
  end

  # GET /user_columns/1
  # GET /user_columns/1.xml
  def show
    @user_column = UserColumn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_column }
    end
  end

  # GET /user_columns/new
  # GET /user_columns/new.xml
  def new
    @user_column = UserColumn.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_column }
    end
  end

  # GET /user_columns/1/edit
  def edit
    @user_column = UserColumn.find(params[:id])
  end

  # POST /user_columns
  # POST /user_columns.xml
  def create
    @user_column = UserColumn.new(params[:user_column])

    respond_to do |format|
      if @user_column.save
        format.html { redirect_to(@user_column, :notice => 'UserColumn was successfully created.') }
        format.xml  { render :xml => @user_column, :status => :created, :location => @user_column }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_columns/1
  # PUT /user_columns/1.xml
  def update
    @user_column = UserColumn.find(params[:id])

    respond_to do |format|
      if @user_column.update_attributes(params[:user_column])
        format.html { redirect_to(@user_column, :notice => 'UserColumn was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_columns/1
  # DELETE /user_columns/1.xml
  def destroy
    @user_column = UserColumn.find(params[:id])
    @user_column.destroy

    respond_to do |format|
      format.html { redirect_to(user_columns_url) }
      format.xml  { head :ok }
    end
  end
end
