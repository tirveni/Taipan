/*
* Taipan: xutils.js
*
    Copyright (C) 2016,  Tirveni Yadav

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*
*/

var $progress_clock = "<div class='preloader-wrapper active red-text'>"
      							+ "<div class='circle-clipper left'>"
        									+ "<div class='circle'></div>"
    								+ " </div>I"
								+ "</div>"; 

var $progress_bar = "<div class='progress'><div class='indeterminate'></div></div>";

//REST Page Current Div
var $rpage_current = "#api_page_current";

var $g_sign_pass =" &#x2611 "
var $g_sign_fail =" &#x2612 ";

var $zebra_a = " " + "  " + " ";
var $zebra_b = " " + " grey lighten-3 " + " ";

//Used in Bill txns, Change colors for debugging
var $btx1_color = " white blue-text ";
var $btx2_color = " white black-text  ";
var $btx3_color = " white blue-text ";
var $btx4_color = " white accent-1 ";

var $div_entity_more			= '#x_extra_more';
var $div_entity_more_below = '#x_extra_more_below';
var $rest_msg_out 	= "#rest_messages";

var $c_ajax_timeout_milisec			= 10000;//MiliSeconds


/************************/


/*
* Empty div Rest_Message
* FX: bx_empty_rest_messages
* 
*/
function g_empty_rest_messages()
{
	var $div_mr = "#rest_messages";
	$($div_mr).empty();
		
}


/*
*
* Removes the Toast Class(popups)
* FX: bx_toast_empty
*/
function bx_toast_empty($div_id)
{
	$(".toast").remove();
}



/*
* FX:bx_display_error(fail_or_success,msg,error_code)
* Displays: Success if first argument is greater than zero.
*
*/
function bx_display_error($make_empty,$message,$error_code)
{
	
	var $div_err = "#rest_messages";   
	if($make_empty > 0 && $message)
	{
			$($div_err).empty();
 			$($div_err).append($message);	
 			return ;	
		
	}
	else if($make_empty > 0)
	{
			$($div_err).empty();
 			return ;	
	}
	else
	{
			$($div_err).empty();
			var $str_err = "<span class='red-text'>&nbsp; &#9746 "+ $message +"."
 								+ "</span>";
			Materialize.toast($str_err, 3000);
 			$($div_err).append($str_err);	
	}
	
	return ;
}

/*
* FX: bx_extract_err_msg(xhr,$str_fn_name)
* Returns: Error Msg

*/
function bx_extract_err_msg(xhr,$fn)
{
	var $err_msg = "xhr: unknown error " + $fn;	
	var $jr;

	if (xhr.readyState == 0) 
	{
         $err_msg = "Network Connection Failure.";
   }
	else if(xhr.responseText)
	{
		$jr 		= JSON.parse(xhr.responseText) ;
		if($jr.error)
		{
			$err_msg = $jr.error;
		}  
		
	}  

	return $err_msg;
									
}


/*
* FX:progress_append(div_id,message,retry_function) 
* @params: div:#id, Message, Retry_function
*  display Progress Bar to a div, with a Message.
* 
*/
function progress_append($div_id,$message,$function_retry)
{
	var $msg = $message || "Loading...";
	var $fnx = "";
	if($function_retry)
	{
			$fnx = "  <span class='btn red' onClick='"+ $function_retry +"' > Retry </span>";
	}	
	
	bx_progress_empty($div_id);
	var $msg_progress = "<span class='msg_progress red-text'>"
		+ $msg + $progress_clock + $fnx + "</span>";
	
	$($div_id).append($msg_progress);

}

/*
*
* FX: bx_progress_empty
* Removes Progress Animation from the Div.
*
*/
function bx_progress_empty($div_id)
{
	$($div_id).find('.msg_progress').remove();	
}



/*
* Set Title of The Page
* FX: bx_set_title(string)
*/

function bx_set_title($in_value)
{
	if($in_value)
	{
		document.title = $in_value;
	}
	return $in_value;		
}

/*** Date and Time ***/

/*
* FX: g_choosen_date(date)
*
* Returns: choosen date
* Use with DatePicker.js, like This
* <input type="hidden"    class='xindate' />
* <input type="date" id='in_date' class='xindate datepicker' size='12'/>
*
*/
function g_choosen_date($xinput)
{
	var $xdate;
	if($xinput)
	{
		//$xdate = $(".xindate").data($xinput);
		//How to handle both: todo.
		$xdate = $(".xindate").val($xinput);
	}	
	else
	{
		$xdate = $("#in_date").val(); 
	}
	
	return $xdate;
	
}



/************* User LoggedIn Stuff. ***/
/* 
* This function is to check if user is logged
* @params: divid
* AJAX: GET
* 
*/
function	gx_is_user_logged($div_add) 
{
	var $url = '/g/user';

	$.ajax( 
				{ 
					url: 			$url ,
					type: 		"GET",
					timeout: 	5000, 
					dataType: 	"json",
 					error: function (xhr,status,error) 
 					{
 						var $me = "<span class='red-text'>Information cannot be received about the user."
 								+ "</span>";
            	},
					success: function(xdata)
					{
						var $userid = g_user_login(xdata);
						$($div_add).append($userid);
					},
				}	
	);		
	
	return ;
		
}

/*
* FX: g_user_login: gets the current login
* Msg based on logged in or not.IF User is not Logged then Toast: User is not logged in.Else Nothing
* 
* @returns: UserID.
*
*/
function	g_user_login(xdata)
{
	if(xdata.userid == 'UNKN' )
	{
		var $msg = "User is not logged in";
		Materialize.toast($msg, 5000);							
	}
	else
	{
		//Materialize.toast("Logged In", 5000);
		return xdata.userid; 
	}
}

/*
* MST: Login Form
*
*/

var $mst_form_login ="<div class='card-panel'>"
	+ "<div class='row '>"
			 + "<div class='col s12 red-text'>"
			 		+ "<h5>Taipan</h5>"
			 	+ "</div>"
			 + "<div class='col s12'>"
			 		+ "Sign in to continue"
			 	+ "</div>"
		+ "</div>"
	+ "<div class='row '>"
       + "<div class='input-field col s12'>"
		       + "     <input id='userid' type='email' name='userid' class='validate' />"
			    + "     <label for='userid' data-error='Wrong Email'>"
		   	 + "	      	Email or phone</label>"
       + "</div>"
	+ "</div>"
        
   + "<div class='row '>&nbsp;</div>"
   + "<div class='row '>"
        + "  <div class='input-field col s12'>"
        + "    <input id='password' type='password' name='password' class='validate' required>"
        + "    	<label for='password' >Password"
        + "    		</label>"
        + "  </div>"
   + "</div>"
        
   + "<div class='row'>"          
        + "  <div class='input-field col s12 m12 l12  login-text'>"
        + "      <input type='checkbox' id='remember-me' />"
        + "      <label for='remember-me'>Remember me</label>"
        + "  </div>"
   + "</div>"
        
   + "<div class='row'>"
   	  + "  <span id='progress_sign_in'></span>"
        + "  <button class='col s10 m10 l10 offset-s1 offset-l1 offset-m1 " 
        + "  					btn waves-effect waves-light green' type='button' "
        + " onClick='g_sign_in();' > "
        + "  		&#x279f; &#x25a1;   Sign In" 
  		  + "	 </button>"
   + "</div>" 	

   + "<div class='row'>"            		
        + "  <a 		class='col s10 m10 l10 offset-s1 offset-l1 offset-m1 " 
        + " 		btn waves-effect waves-dark red-text white border' " 
        + "  					href='/login/forgot_password' > "
        + "  						<b>Forgot password ? </b> "
        + "    	</a>"
   + "</div>" 	
   + "<div class='row'> "
        + "    <a class='col s10 m10 l10 offset-s1 offset-l1 offset-m1 "
        + "   		btn white border blue-text  waves-effect waves-dark' href='/registration'> "
        + "    		Register Now! "
        + "    		<b>&#9998;</b>"
        + "    	</a>"
	+ "	</div>"
				

   + "<div class='row'>"            		
        + "    <a class='col s10 m10 l10 offset-s1 offset-l1 offset-m1 "
        + "			btn white border blue-text  waves-effect waves-dark' href='/registration/validate'> "
        + "    			Verify Email Address</b></a>"
        + " </div>"
   + "</div>"  
        ;


/*
*
* FX: gx_form_sign: Create a Form for Sign In
* 
*/
function gx_form_sign($in_div)
{
	var $str_div;	
	var $str_div = Mustache.to_html($mst_form_login);

	if($in_div)
	{
		$($in_div).append($str_div);
	}

	return $str_div;	
}

/*
* FX: g_sign_in
* Sign In Form: Checks the Data
* Checks through AJAX API: /g/user/login
*
*/
function g_sign_in()
{
	var $userid 	= $("#userid").val();
	var $password	= $("#password").val();
	
	$h_user = {
					userid: $userid,
					password: $password,
			    };
		
	var $url = "/g/user/login";	
	var $progress_msg = $progress_clock + "Please wait.....";
	var $div_wait = "#progress_sign_in";
	
	if(!$userid || !$password)
	{
			bx_toast_empty();
			Materialize.toast("User ID or password is missing", 5000);
			$($div_wait).empty();	
	}
	else if($userid && $password && $url )
	{
				bx_toast_empty();
				Materialize.toast($progress_msg, 5000);
				$($div_wait).append($progress_msg);
								
				$.ajax( 
							{ 
								url: 			$url ,
								type: 		"POST",
								timeout: 	5000,
								data:			$h_user, 
								dataType: 	"json",
		 						error: function (xhr, status, error) 
 								{
									$($div_wait).empty();
 									bx_toast_empty();
	 								var $error_msg = bx_extract_err_msg(xhr);
									Materialize.toast($error_msg, 5000);			 								
			            	},
								success: function(xdata)
								{
									$($div_wait).empty();
									bx_toast_empty();
									Materialize.toast("You have signed in.", 5000);
									window.location.href = '/home';
								},
							}	
				);// ajax		
		
	}	
	
	
}

/************* User LoggedIn Stuff. END	 ***/


