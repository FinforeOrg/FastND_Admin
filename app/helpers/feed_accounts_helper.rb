module FeedAccountsHelper
  def account_category_list(feed_account)
    lists = "<ul>"
    ["company","facebook","google","linkedin","podcast","portfolio","price","rss","search","twitter"].each do |category|
      lists << "<li>"
      lists << link_to(image_tag("social/#{category}.png",
                                 :style=>"padding:8px;border:0px;width:38px;height:38px;",
                                 :alt=>category,
                                 :title=>category),"#additional_section",:alt=>category)
      lists << "<BR/>#{category}"
      lists << "</li>"
    end
    lists << "</ul>"
    lists << "<script>"
    lists << '$("li").not(".minmax").find("a").click(function(){'
#    lists << '$("#additional_section ul li a").click(function(){'
    lists << "  var _category = $(this).attr('alt');"
    lists << '  if(_category.match(/google|linkedin|twitter|portfolio/i)){'
    lists << "    document.location = document.location.protocol+'//'+document.location.host+'/users/#{feed_account.user.id}/feed_accounts/column_auth?provider=' + _category;"
    lists << '  }else{'
    lists << "    load_by_element('/users/#{feed_account.user.id}/feed_accounts/new?category='+_category,$('#additional_section'));}"
    lists << '});'
    lists << "</script>"
    lists.html_safe
  end

  def form_title(account)
    if account.name.blank?
      "Create New #{account.category}"
    else
      account.name
    end
  end

  def token_name(feed_account)
    if feed_account.feed_token && !feed_account.feed_token.uid.blank?
      feed_account.feed_token.uid
    elsif feed_account.name
      feed_account.name
    else
      "- protected -"
    end
  end


end
