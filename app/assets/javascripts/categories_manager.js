$(document).on("turbolinks:load", () => {
	$("#categories_list li").click(function(event){
	  event.stopPropagation();

	  var id = $(event.target).attr("id");
	  if (typeof(id) !== "undefined") {
		  id = id.split(/_(.+)/)[1];
		  
		  if ($(event.target).parents("li").find("span#category_" + id).is(":visible")){
			  $.ajax({
			  	type: "GET",
			  	dataType: "html",
			  	url: "/api/v1/forms/edit_category/" + id,
			  	success(data) {
			  		hideEditForms();

			  		$(event.target).parents("li").find("span#edit_category_" + id).addClass("active_form");
			  		$(event.target).parents("li").find("span#category_" + id).hide();
			  		$(event.target).parents("li").find("span#edit_category_" + id).show();
			  		$(event.target).parents("li").find("span#edit_category_" + id).html(data);
			  	}
			  });
		  }
	  }
	});
});

// close the symbols dropdown when clicking outside of it
$(document).mouseup(function(e) {
  var $container = $(".dropdown-menu-symbols");

  if($container.is(":hidden")) {
    return false;
  } else if (typeof($(e.target).parents(".dropdown-menu-symbols").attr("class")) === "undefined") {
  	$container.hide();
  }
});

// hide edit forms when clicking outside of them
$(document).mouseup(function(e) {
	var $container = $("#categories_list li .active");

	if($container.is(":hidden")) {
		return false;
	} else if (typeof($(e.target).parents(".active_form").attr("class")) === "undefined") {
		hideEditForms();
	}
});

function hideEditForms() {
	$("#categories_list li .active_form").each(function() {
		$(this).html("");
		$(this).hide();
		$(this).parents("li").find("span.category_html").show();
	});
}

// search symbols
function searchCategorySymbol(obj) {
	var text = $(obj).val().replace(/[^a-z0-9]/gi,"");
	var symbLength, symbPos, symb, name;
	var symbArr = $(obj).parents(".dropdown-menu-symbols").find(".category_symbol").toArray();

	symbLength = symbArr.length;
	symbPos = 0;

	while (symbPos < symbLength) {
    symb = $(symbArr.pop());

    name = $(symb).attr("name").replace(/[^a-z0-9]/gi,"");
    
    if(name.toUpperCase().indexOf(text.toUpperCase()) === -1) {
    	$(symb).hide();
    } else {
    	$(symb).show();
    }

    symbPos += 1;
  }
}

function setCategoryColor(obj) {
	var color = $(obj).parents(".row").find("#category_color").val();
	$(obj).parents(".row").find(".dropdown-toggle-symbols").attr("color", color);
	$(obj).parents(".row").find(".symbol_field i.category").css("background-color", $(obj).parents(".row").find(".dropdown-toggle-symbols").attr("color"));
}

function selectCategorySymbol(obj) {
	var color = $(obj).parents(".row").find(".symbol_field i.category").css("background-color");

	$(obj).parents(".category_symbol_field").find("#category_symbol").val($(obj).attr("name"));
	$("button#dropdownMenuSymbols").html($(obj).find(".symbol").html());
	$(obj).parents(".row").find(".symbol_field i.category").css("background-color", color);
	$(".dropdown-menu-symbols").hide();
}