module NoticeboardUsersHelper
  def is_active(noticeboard,member)
    style = member.is_active ? "on_tab" : "add_tab"
    link_to image_tag("layout/space.png",:class=>style,:border=>0),update_status_noticeboard_noticeboard_user_path({:noticeboard_id=>noticeboard.id,:id=>member.id}),:class=>"ct_status"
  end
end
