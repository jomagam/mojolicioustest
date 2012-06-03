#!/usr/bin/perl

use Mojolicious::Lite;
use Stuff;

get  '/' => 'index';

post '/ajax' => sub { Stuff::ajaxhandler(shift) };

app->start;



__DATA__

@@ index.html.ep
<!DOCTYPE HTML>
<html>
    <head>
        <style type="text/css">
	    .favorite { color: red}
	    .auser    { padding: 5px}
	</style>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
	<script type="text/javascript">
	    COMMUNISATION_TIMEOUT = 500;
	    $(document).ready(function() {
		 $(document).on("click", ".favorite_link", make_favorite);
		 $(document).on("click", ".unfavorite_link", remove_favorite);
		 $(document).on("click", ".remove_link", remove_link_action);
		 $("#addbutton").click(addnewuser);
		 $("#clearerrors").click(function(){
		    $("#error_texts").html("");
		    $("#errors").hide("slow");
		 });
	    });
	    function remove_link_action(){
		var id = $(this).parent().attr('id');
		$("#" + id).hide('slow');

		var success = 0;
		var handled_error = 0;
		var undo_func = function(){
		    $("#" + id).show('slow');
		};

		setTimeout( function(){
		    if(handled_error == 0 && success == 0){
			undo_func();
			raise_error(id + " could not be removed: timeout of " + COMMUNISATION_TIMEOUT);
		    }
		}, COMMUNISATION_TIMEOUT);

		$.post("/ajax", { function: 'remove', user: id}, function(json){
		    if(json.result == 'OK'){
		        success = 1;
		    }
		    else {
		        if(handled_error == 0){
			    undo_func();
			    raise_error(id + " could not be removed:" + json.result);
			}
		    }
		}, "json");
	    }
	    function make_favorite(){
		var id = $(this).parent().attr('id');
		$(this).removeClass('favorite_link')
		$(this).addClass('unfavorite_link');
		$("#" + id + '_name').removeClass('notfavorite').addClass('favorite');
		$("#" + id + '_fave_change_text').text('Unfavorite');

		var success = 0;
		var handled_error = 0;
		var undo_func = function(){
		    handled_error = 1;
		    $(this).removeClass('unfavorite_link');
		    $(this).addClass('favorite_link');
		    $("#" + id + '_name').removeClass('favorite').addClass('notfavorite');
		    $("#" + id + '_fave_change_text').text('Favorite');
		};

		setTimeout( function(){
		    if(handled_error == 0 && success == 0){
			undo_func();
			raise_error(id + " could not be updated: timeout of " + COMMUNISATION_TIMEOUT);
		    }
		}, COMMUNISATION_TIMEOUT);

		$.post("/ajax", { function: 'yesfavorite', user: id}, function(json){
		    if(json.result == 'OK'){
		        success = 1;
		    }
		    else {
		        if(handled_error == 0){
			    undo_func();
			    raise_error(id + " could not be updated:" + json.result);
			}
		    }
		});
	     }
	    function remove_favorite(){
		var id = $(this).parent().attr('id');
		$(this).removeClass('unfavorite_link');
		$(this).addClass('favorite_link');
		$("#" + id + '_name').removeClass('favorite').addClass('notfavorite');
		$("#" + id + '_fave_change_text').text('Favorite');

		var success = 0;
		var handled_error = 0;
		var undo_func = function(){
		    handled_error = 1;
		    $(this).removeClass('favorite_link');
		    $(this).addClass('unfavorite_link');
		    $("#" + id + '_name').removeClass('notfavorite').addClass('favorite');
		    $("#" + id + '_fave_change_text').text('Unfavorite');
		};

		setTimeout( function(){
		    if(handled_error == 0 && success == 0){
			undo_func();
			raise_error(id + " could not be updated: timeout of " + COMMUNISATION_TIMEOUT);
		    }
		}, COMMUNISATION_TIMEOUT);

		$.post("/ajax", { function: 'nofavorite', user: id}, function(json){
		    if(json.result == 'OK'){
		        success = 1;
		    }
		    else {
		        if(handled_error == 0){
			    undo_func();
			    raise_error(id + " could not be updated:" + json.result);
			}
		    }
		}, "json");
	     };
	     function addnewuser(){
	        var newuser = $("#newuser").val();
		$("#newuser").attr('value', '');
		var d = new Date();
		var newid = newuser + "_" + d.getTime();

		var success = 0;
		var handled_error = 0;

		var undo_func = function(){
		    handled_error = 1;
		    $("#" + newid).hide('slow');
		};

		$("#current_interests").append('<div class="auser" id="' + newid + '"><span class="notfavorite" id="' + newid + '_name">' + newuser + '</span> <a id="' + newid + '_fave_change_link" class="favorite_link" href="#"><span id="' + newid + '_fave_change_text">Favorite</span></a> <a class="remove_link" href="#">Remove</a></div>');
		setTimeout( function(){
		    if(handled_error == 0 && success == 0){
			undo_func();
			raise_error(newuser + " could not be created: timeout of " + COMMUNISATION_TIMEOUT);
		    }

		}, COMMUNISATION_TIMEOUT);
		$.post("/ajax", { function : 'addnewuser', user: newuser}, function(json){
		    if(json.result == "OK"){
			success = 1;
		    }
		    else {
		        if(handled_error == 0){
			    undo_func();
			    raise_error(newuser + " could not be created: " + json.result);
			}
		    }
		}, "json");
	     }
	     function raise_error(text){
	        $("#error_texts").append('<div>' + text + '</div>');
		$("#errors").show('slow');
	     }
	</script>
	<style>
	    a.ajax {
		text-decoration: none;
		border-bottom: 1px dashed;
	    }
	    a.ajax:hover {
		text-decoration: none;
		border-bottom: 1px dashed;
	    }
	</style>
    </head>
    <body>
	<div id="errors" style="color:red; display:none; padding: 20px">
	<h2>ERRORS</h2>
	<div id="error_texts">
	</div>
	<div>
	<input type="button" id="clearerrors" value="Got it">
	</div>
	</div>
	<div>
	    Add: <input type="text" width="12" id="newuser"> <input type="button" value="Add" id="addbutton">
	</div>
	<div id="current_interests">
	<%==
	    Stuff->current_interests;
	%>    
	</div>
    </body>
</html>
