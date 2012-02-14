module UsersHelper
  def menu_edit_user(user)
    submenus = '<ul class="section_menu left form_tab">'
      submenus << "<li>"
        submenus << main_menu("Edit","/users/#{user.id}/edit","edit,update".include?(controller.action_name) ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Columns","/users/#{user.id}/columns",controller.action_name == "columns" ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Company Tabs","/users/#{user.id}/company_tabs",controller.action_name == "company_tabs" ? true : false, true)
      submenus << "</li>"
    submenus << "</ul>"
    submenus.html_safe
  end

  def is_public(user)
    style = user.is_public ? "on_tab" : "add_tab"
    link_to image_tag("layout/space.png",:class=>style,:border=>0),update_public_user_path(user),:class=>"ct_status"
  end
end
