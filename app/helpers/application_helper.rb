# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def main_menu(name,path,is_selected,is_ajax=false)
    selected = is_selected ? 'selected_lk' : ''
    tags  = []
    tags.push(content_tag(:span, content_tag(:span,""), :class => "l"))
    
    m_tags = []
    m_tags.push(content_tag(:em,name))
    m_tags.push(content_tag(:span, ""))
    
    m_tag = content_tag :div, :class => "m" do
      m_tags.collect{ |item| concat(item)}
    end
    
    tags.push(m_tag)
    
    tags.push(content_tag(:span, content_tag(:span,""), :class => "r"))
    
    if is_ajax
     a_link =  content_tag :a, :class => "selected", :location => path, :href => "#form_area" do
        tags.collect{|item| concat(item)}
      end
    else
     a_link =  content_tag :a, :class => "selected", :href => path do
        tags.collect{|item| concat(item)}
      end
    end
  
    return a_link

  end

  def dashboard_menu(name,path,icon)
    link_to path, {:class => icon} do
      content_tag(:span, name)
    end
  end

  def sub_menu_focuses(is_displayed)
    submenus = ""
    if is_displayed
      submenus = "<ul>"
        submenus << "<li>"
          submenus << main_menu("Categories","/focuses",controller.controller_name == "profile_categories" ? true : false)
        submenus << "</li>"
        submenus << "<li>"
          submenus << main_menu("Focuses","/profiles",controller.controller_name == "profiles" ? true : false)
        submenus << "</li>"
      submenus << "</ul>"
    end
    return submenus.html_safe
  end

  def sub_menu_suggestions(is_displayed)
    submenus = ""
    if is_displayed
      submenus = "<ul>"
        submenus << "<li>"
          submenus << main_menu("Non-Prices","/feed_infos",(controller.action_name != "prices"))
        submenus << "</li>"
        submenus << "<li>"
          submenus << main_menu("Prices","/feed_infos/prices",(controller.action_name == "prices"))
        submenus << "</li>"
      submenus << "</ul>"
    end
    return submenus.html_safe
  end

  def partial_user_menu
    partial_name = "form"
    if controller.action_name == "columns"
      partial_name = "columns"
    elsif controller.action_name == "company_tabs"
      partial_name = "company_tabs"
    end
    render partial_name
  end

  def user_form_ajax
    ajax = '<script>'
    ajax << '$(".form_tab a").click(function(){'
    ajax << '    hideLoading();'
    ajax << '  showLoading();'
    ajax << '  $.get($(this).attr("location"),function(response){'
    ajax << '    hideLoading();'
    ajax << '    if($("#form_area").length > 0){'
    ajax << '      $("#form_area").html(response);'
    ajax << "    }else{"
    ajax << "     if($('#additional_section').length > 0){"
    ajax << "        _sections = $('#additional_section').parent().children().first();"
    ajax << '     }else{'
    ajax << "       _sections = $('.form_tab a').parents('div.section');"
    ajax << "     } "
    ajax << "     _parent = $(_sections).parent();"
    ajax << '     $(_sections).remove();'
    ajax << '     $(_parent).prepend(response);'
    ajax << '    }'
    ajax << '  });'
    ajax << '});'
    ajax << '</script>'
    ajax.html_safe
  end

  def timeformat_full(stamp,img_w=14,img_h=14)
    stamp_format = ""
    if stamp
      stamp_format << stamp.strftime('%a, %d %b %Y ')
      #stamp_format << image_tag("clock.png",:width=>img_w,:height=>img_h)
      stamp_format << stamp.strftime(' %H:%M')
    end
    stamp_format
  end

  def dateformat_full(stamp)
    stamp.strftime('%a, %m %b %Y') if stamp
  end

  def feed_info_image(info)
    image_source = "/assets/no_picture.gif"
    if info.image.blank?
      category_image(info.category)
    else
      image_source = info.image
    end
  end

  def category_image(category = "")
    image_source = "/assets/no_picture.gif"
    category = category.to_s
    if category.downcase == "rss"
      image_source = "/assets/social/rss.png"
    elsif category.downcase == "twitter"
      image_source = "/assets/social/twitter.png"
    elsif category.downcase == "company"
      image_source = "/assets/social/company.png"
    elsif category.downcase == "keyword"
      image_source = "/assets/social/search.png"
    elsif category.downcase.scan(/podcast|video|media/i).size > 0
      image_source = "/assets/social/podcast.png"
    elsif category.downcase == "chart" || category.downcase == "price"
      image_source = "/assets/social/price.png"
    elsif category.downcase == "gmail" || category.downcase == "google"
      image_source = "/assets/social/google.png"
    elsif category.downcase == "portfolio"
      image_source = "/assets/social/portfolio.png"
    elsif category.downcase == "linkedin"
      image_source = "/assets/social/linkedin.png"
    end
  end

  def has_suggest(category)
    return category.downcase.scan(/gmail|google|portfolio|facebook|linkedin|keyword/i).size < 1
  end

  def feed_info_detail(info)
    if info.category.downcase.scan(/rss|podcast|video/i).size > 0
      link_to image_tag("layout/loupe.gif",:border=>0),info.address,:title=>"View",:target=>"_blank"
    else
      "<br/> #{truncate(info.category, :length => 100, :separator => '...')}".html_safe
    end
  end

  def protect_string(str="")
    CGI::escape(str)
  end

end
