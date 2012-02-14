module NoticeboardsHelper
  
  def menu_edit_noticeboard(noticeboard)
    submenus = '<ul class="section_menu left form_tab">'
      submenus << "<li>"
        submenus << main_menu("Edit","edit",noticeboard_selected, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Members","noticeboard_users",controller.controller_name == "noticeboard_users" ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Posts","noticeboard_posts",controller.controller_name == "noticeboard_posts" ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Comments","noticeboard_comments",controller.controller_name == "noticeboard_comments" ? true : false, true)
      submenus << "</li>"
    submenus << "</ul>"
  end

  def noticeboard_selected
    return false if controller.controller_name != "noticeboards"
    "edit,update".include?(controller.action_name) ? true : false
  end
  
end
