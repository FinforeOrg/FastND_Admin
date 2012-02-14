module FeedInfosHelper

  def tag_on_list(info)
    if controller.action_name != "prices"
      "loading ..."
    else
      truncate(info.price_tickers.map(&:ticker).join(", "), :length => 86, :separator => ' ...')
    end
  end

  def is_tab(info)
    style = info.company_competitor ? "on_tab" : "add_tab"
    link_to image_tag("layout/space.png",:class=>style,:border=>0),tab_config_feed_info_path(info),:class=>"ct_status"
  end

  def is_populate(info)
    style = info.is_populate ? "on_populate" : "add_populate"
    link_to image_tag("layout/space.png",:class=>style,:border=>0),populate_config_feed_info_path(info),:class=>"ap_status"
  end

  def menu_edit_prices(info)
    submenus = ""
    if info.category == "Chart"
      submenus = '<ul class="section_menu left form_tab">'
        submenus << "<li>"
          submenus << main_menu("Edit","/feed_infos/#{info.id}/edit","edit,update".include?(controller.action_name) ? true : false, true)
        submenus << "</li>"
        submenus << "<li>"
          submenus << main_menu("Tickers","/feed_infos/#{info.id}/tickers",controller.action_name == "tickers" ? true : false, true)
        submenus << "</li>"
        submenus << "<li>"
          submenus << main_menu("Users","/feed_infos/#{info.id}/users",controller.action_name == "users" ? true : false, true)
        submenus << "</li>"
      submenus << "</ul>"
    end
    submenus.html_safe
  end
  
end
