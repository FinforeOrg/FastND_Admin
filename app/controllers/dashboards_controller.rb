class DashboardsController < ApplicationController
  before_filter :before_render
  require 'net/http'

  def index
  end

  def chart_users
    clear_range if params[:end_at] == params[:start_at] || params[:end_at].blank? || params[:start_at].blank?
    clear_range if !params[:end_at].blank? && !params[:start_at].blank? && params[:start_at].to_date > params[:end_at].to_date
    params[:end_at] = Time.now.midnight if params[:end_at].blank?
    params[:start_at] = params[:end_at].ago(1.month) if params[:start_at].blank?
    users = User.where(:created_at => {"$gte" => params[:start_at].to_time, "$lt" =>  params[:end_at].to_time}).asc(:created_at)
    cols = [{:id => 'date',:label => "Date",:type  => "string"},
            {:id => 'number',:label => "New Users",:type  => "number"}]
    rows = []
    start_date = params[:start_at].to_time
    end_date = params[:end_at].to_time
    while(start_date < end_date)
      total = users.select{|u| u if u.created_at >= start_date && u.created_at < start_date.tomorrow}.size
      rows << {:c => [{ :v => start_date.strftime('%d/%m/%y') },{:v=>total}]}
      start_date = start_date.tomorrow
    end
    respond_to do |format|
      format.xml  { render :xml => {:cols=>cols,:rows=>rows} }
      format.json  { render :json => {:cols=>cols,:rows=>rows} }
    end
  end

  def chart_suggestion
    feed_infos = FeedInfo.top_ten(params[:category])
    cols = [{:id => params[:category],:label => params[:category],:type  => "string"},
            {:id => 'number',:label => "Users",:type  => "number"}]
    rows = []
    feed_infos.each do |info|
      rows << {:c => [{ :v => info.title },{:v=>info.follower.to_i}]}
    end
    respond_to do |format|
      format.xml  { render :xml => {:cols=>cols,:rows=>rows} }
      format.json  { render :json => {:cols=>cols,:rows=>rows} }
    end
  end

  def ip_info
    h = Net::HTTP.new('www.ipaddressapi.com')
    response = h.get("/lookup/#{params[:ip]}")
    info = "failed to check!"
    
    if response.message == "OK"
      co = response.body.scan(/<table(\s\w+?[^=]*?="[^"]*?")*?\s+?id="(\S+?\s)*?ipinfo(\s\S+?)*?".*?>(.*?)<\/table>/ixsm)[0].join.gsub(/\n/ixsm,"")
      info = co.gsub(/(<tr><th>)|(<\/th><td>)/ixsm,"").gsub(/<\/td><\/tr>/ixsm,"<br/>")
      info = info.gsub('/flags/','http://www.ipaddressapi.com/flags/')
    end
    respond_to do |format|
      format.html {render :text=>info}
    end
  end

  private
    def before_render
      @dashboard_selected = true
    end

    def clear_range
      params[:end_at] = nil
      params[:start_at] = nil
    end
end
