function showLoading(){
  $.loading(true,{text: 'Loading...',align: 'top-center'});
}

function count_service(_path,_elName,_pathCallBack){
 $.get(_path, function(response){
   if(_pathCallBack == "#"){
     $(_elName).html(response);
   }else{
     $(_elName).html('<a href="'+_pathCallBack+'">'+response+'</a>');
   }
 });
}

function hideLoading(){
  $.loading(false);
}

function _ajax_request(url, data, callback, type, method) {
    if ($.isFunction(data)) {
        callback = data;
        data = {};
    }
    return $.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
        });
}

function deleteMe(options){
  if(options.title){
    options.title = unescape(options.title).replace("+", " ")}

  var _hash = undefined;
  if(options.path.indexOf("#") != -1){
   _hash = options.path.substring(options.path.indexOf("#"));
   options.parent = $(_hash);
   options.path = options.path.substring(0,options.path.indexOf("#"));
  }

  var _parent = _hash ? options.parent : $("#form_area");

  $( "#dialog:ui-dialog" ).dialog( "destroy" );
  $('.delete_title').html(options.title);
  $( "#dialog-confirm" ).dialog(
    {minHeight:200,
     minWidth:200,
     modal: true,
     buttons: {"Delete": function() {
                  $( this ).dialog( "close" );
                  showLoading();
                  _ajax_request(options.path,{},function(){
                    hideLoading();
                    $(options.element).slideUp('slow',$(options.element).remove());
                    if(_hash){$(_parent).slideUp();}
                  },'html', 'DELETE');
                },Cancel: function() {
                    $( this ).dialog( "close" );
                }
              }
    });
}

function success_alert(message){
  $( "#dialog:ui-dialog" ).dialog( "destroy" );
  $('.success_message').html(message);
  $( "#dialog-success" ).dialog(
    {resizable: false,
     height:200,
     modal: true,
     buttons: {"OK": function() {
                  $( this ).dialog( "close" );
                }
              }
    });
}

function open_form(path){
  var _el = $("#form_area");
  if(path.indexOf("#") != -1){
   _el = $(path.substring(path.indexOf("#")));
   path = path.substring(0,path.indexOf("#"));
  }
  load_by_element(path,_el);
}

function load_by_element(path,el){
  hideLoading();
  showLoading();
  $(el).slideUp('normal');
  $.get(path,function(response){
    hideLoading();
    if($(".minmax a").length > 0){
      $(".minmax a").each(function(obj){
        if ($(this).find("img").first().attr("src").match(/minimize/i)){
          $(this).click()
        }
      });
    }
    $(el).html(response);
    $(el).slideDown('normal');
  })
}

function closeMe(el){
  $(el).fadeOut('slow');
}

function loadUserChart(){
  if($(".user_chart").length > 0){
    $.get("/dashboards/chart_users.json",function(data){
      processRegistrationChart(data);
    },"json");
  }
}

function loadSuggestionChart(_counter,_suggestions){
  if(_counter < _suggestions.length){
    _el = $("."+_suggestions[_counter]+"_chart");
    if($(_el).length > 0){
      $.get("/dashboards/chart_suggestion.json?category="+_suggestions[_counter],function(response){
        _dataTable = new google.visualization.DataTable(response);
        _chart = new google.visualization.PieChart($(_el)[0]);
        _chart.draw(_dataTable, {title: _suggestions[_counter].replace(/chart/i,'price').toUpperCase()});
        loadSuggestionChart(_counter+1,_suggestions);
      },"json");
    }
  }
}


function processRegistrationChart(data){
  /*$(data.rows).each(function(obj) {
    data.rows[obj].c[0].v = new Date(data.rows[obj].c[0].v);
  });*/
  _size = data.rows.length;
  _title = "Periode:"+data.rows[0].c[0].v+" - "+ data.rows[_size-1].c[0].v;

  var dataTable = new google.visualization.DataTable(data);
  var chart = new google.visualization.ColumnChart($(".user_chart")[0]);
  chart.draw(dataTable, {title: 'Registration Traffic',hAxis: {title: _title, titleTextStyle: {color: 'blue'}}});
}

$(document).ready(function(){
  $("li.minmax").live("click",function(){
    var _imageBtn = $(this).find("img");
    var _imgBtnSrc = $(_imageBtn).attr("src");
    if($(_imageBtn).attr("src").match(/minimize/i)){
      $(this).parents("div.section").children("div.section_content").slideUp("slow",
        function(){
          $(_imageBtn).attr("src",_imgBtnSrc.replace(/minimize/i,"maximize").replace(/\-.*?.png/,".png"));
        });
    }else{
      $(this).parents("div.section").children("div.section_content").slideDown("slow",
        function(){
          $(_imageBtn).attr("src",_imgBtnSrc.replace(/maximize/i,"minimize"));
        });
    }
  })

  $(".delete, .edit").live("click",function(){
    if($(this).attr("class")=="edit"){
      open_form($(this).attr('href'));
    }else{
      deleteMe({ title: $(this).attr('title'),
                 path: $(this).attr('href'),
                 element: $(this).parents("tr")
              });
    }
    return false;
  });
  


  $(".edit_inline").live("click",function(){
  
	  _el = this;
  
	  showLoading();
 
	  $.get($(_el).attr('href'),function(response){
    
	     hideLoading();
    
	     $(_el).parents("ul").first().fadeOut("normal",function(){
       
  	            $(_el).parents("div.actions_menu").append(response);
    
	     });
   
	  });
    
	  return false;
 
  });
  
  
  /* for noticeboard user */
 
  $(".cancel_form").live("click",function(){
   
	 $(this).parents("div.forms_wrapper").fadeOut("normal",function(){
     
	   $(this).parents("div.actions_menu").find("ul").fadeIn();
     
	   $(this).parents("div.forms_wrapper").remove();
   
	 });
    
	 return false;
 
  });
  


  $('#role_user_form').live("submit",function(){
   
	  hideLoading();showLoading();
    
	  _el = this;
    
	  $.post($(_el).attr("action"),
	  $(_el).serialize(),function(response){
     
	    hideLoading();
      
	    $(_el).parents("div.actions_menu").html(response);
    
	  });
     
	  return false;
 
  });


  $(".ct_status, .ap_status").live("click",function(){
    _uri = $(this).attr('href');
    _child = $(this).children("img").first();
    _child_class = $(_child).attr("class");

      showLoading();
      $.get(_uri,function(response){
        hideLoading();
        if(response == "FAILED"){
          alert('An error is occurred, please refresh your page');
        }else{
          $(_child).fadeOut('slow',function(){
            if(_child_class.match(/tab/i)){
              _new_class_name = _child_class=="on_tab" ? "add_tab" : "on_tab";
            }else{
              _new_class_name = _child_class=="on_populate" ? "add_populate" : "on_populate";
            }
            $(_child).attr("class",_new_class_name);
            $(_child).fadeIn('normal');
          });
        }
      })

    return false;
  });

});