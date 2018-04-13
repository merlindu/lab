<!DOCTYPE html>
<html>
<head>
<title>Network</title>
 %include('head.tpl')
 %import os
 %os.system("cp /etc/ppp_bak/* /etc/ppp/ -rf")
<script type="text/javascript">
	function wsec()
	{
		var method = "post";
		var eventID = "auto_wifi";	
		var data;	
		wifi_select.style.display='block';
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
			var checkOK = xmlhttp.responseText;
			if(checkOK == "connect ok")
			{
				alert("connect ok")
			}
		});
	}
</script>
<script type="text/javascript">
	function set_wifiap()
	{	
		var ap_name = document.getElementById("ap_name").value;
		var ap_password = document.getElementById("ap_password").value;
		if( ap_password.length < 8 )
		{
			if( ap_password.length != 0 )
			{
				alert("Input error:\n Password length wrong, the minimal is 8. Please try again.");
				return;
			}
			else
			{
				alert("The AP has no password.");
				return;
			}
		}
		if (ap_name.length == 0) {
			alert("The AP has no name.")
			return;
		}
			var method = "post";
			var eventID = "set_ap";
			var data = "ap_name=" + ap_name + "&ap_password=" + ap_password;
			XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
				var checkOK = xmlhttp.responseText;
				alert("set ap success," + checkOK);
			});
	}
</script>
<script type="text/javascript">
function checkboxOnclick(checkbox){
	if ( checkbox.checked == true){
		var method = "post";
		var eventID = "dongle_auto_on";
		var data
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
			var checkOK = xmlhttp.responseText;
		});
	}
	else
	{
		var method = "post";
		var eventID = "dongle_auto_off";
		var data
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
			var checkOK = xmlhttp.responseText;
		});
	}
}
</script>
<script type="text/javascript">
	$(document).ready(function ()
	{
	  	$("#ap_list").bind("change",function()
		{ 
			document.getElementById("password").value="";
  			var ssid = $("#ap_list").val();
			var method = "post";
			var eventID = "select_auto";
			var data = "ssid=" + ssid;
			XMLHttp.sendRequest( method, eventID, data, function(xmlhttp)
			{
				var checkOK = xmlhttp.responseText;
				if (checkOK == "please input password")
				{
					form1.style.display='block';
					butt1.style.display='block';
				}
			}); 
		}); 

	});
</script>
<script type="text/javascript">
	function password_connect()
	{ 
  		var ssid = $("#ap_list").val();
		var save_password=document.getElementById("save_password");
		var pack = save_password.checked;
		var password = document.getElementById("password").value;
		if( password.length < 8 )
		{
			if( password.length != 0 )
			{
				alert("Input error:\n Password length wrong, the minimal is 8. Please try again.");
				return;
			}
		}
		var method = "post";
		var eventID = "password_connect";
		var data = "ssid=" + ssid + "&password=" + password + "&pack=" + pack;
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
			var checkOK = xmlhttp.responseText;
			alert(checkOK);
		});	
	}
</script>

<script type="text/javascript">
	function dongle_on()
	{
		var method = "post";
		var eventID = "dongle_on";
		var data;
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
				var checkOK = xmlhttp.responseText;
				alert(checkOK);
		});
	}
</script>

<script type="text/javascript">
	function dongle_off()
	{	
		var method = "post";
		var eventID = "dongle_off";
		var data;
		XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
				var checkOK = xmlhttp.responseText;
				alert(checkOK);
		});
	}
</script>
<style type="text/css">
.tabs {
  width: 600px;
  height: 300px
  float: none;
  position:relative;
  list-style:none
  text-aling:left;

}
.tabs li {
  float: left;
  display: block;
}
.tabs input[type="radio"] {
  position: absolute;
  top: -9999px;
  left: -9999px;
}
.tabs label {
  display: block;
  border-radius: 10px 10px 0 0;
  font-size: 20px;
  font-weight: normal;
  padding:14px 30px;
  text-transform: uppercase;
  background: 00bfff;
  cursor: pointer;
  position: relative;
  left:-40px;
  top: 4px;
  -webkit-transition: all 0.2s ease-in-out;
  -moz-transition: all 0.2s ease-in-out;
  -o-transition: all 0.2s ease-in-out;
  transition: all 0.2s ease-in-out;
}
.tabs label:hover {
  background: #778899;
}
.tabs .tab-content {
  z-index: 2;
  display: none;
  overflow: hidden;
  padding: 20px;
  font-size: 17px;
  line-height: 20px;
  position: absolute;
  top: 53px;
  border-radius:0 10px 10px 10px;
  left:0; 
  background: #ffffcc;
}
.tabs [id^="tab"]:checked + label {
  top: 0;
  padding-top: 14px;
  background: #ffff99;
}
.tabs [id^="tab"]:checked ~ [id^="tab-content"] {
  display: block;
}

</style>

</head>

<h2 align="center" >Network Configuration</h2>
<body>
<div class="container" >
%include('navi.tpl')
 <div align="center">
  <ul class="tabs" >
   <li>
    <input type="radio" name="tabs" id="tab1" checked/>
     <label for="tab1">AP Mode</label>
       <div id="tab-content1" class="tab-content" style="width:600px; height:250px">
        <fieldset>
 	 <fieldset class="container icat-fieldset-sub1" name="wifi_ap" id="wifi_ap">
		<p style="color:blue; font-size:20px"; align="left";>SSID</p>
		<p align="left"><input class="icat_input_high icat_color_bk" style="width:400px; height:30px; font-size:18px;" type="text" id="ap_name" placeholder="ssid name" name="name"></p>
		<p style="color:blue; font-size:20px"; align="left";>Password</p>
		<p align="left"><input class="icat_input_high icat_color_bk" style="width:400px; height:30px; font-size:18px" type="text" id="ap_password" name="ap_password" placeholder="password" maxlength="16"></p>
		<br>
		<br>
		<div class="btn btn-block btn-primary" align="center" style="width:300px; font-size:16px" type="submit" id="ap_get" onClick="set_wifiap();" >Submit
		</div>
	</fieldset>
       </fieldset>
     </div>
   </li>

   <li>
    <input type="radio" name="tabs" id="tab2" onClick="wsec();" />
     <label for="tab2"> STA Mode</label>
      <div id="tab-content2" class="tab-content" style="width:600px; height:250px">
       <fieldset >
	 <fieldset class="container icat-fieldset-sub1" name="wifi_select" id="wifi_select">
		<p style="color:blue; font-size:20px"; align="left">Wifi Select</p>
		<p align="left"><select style="border:0; color:#0066FF; width:400px;height:30px;font-size:18px" name="ssid" id="ap_list" size="1"></p>

 			%from icatch_funcs import wifi_scan
       			%ap_array = wifi_scan()
		       	 %for ap_t in ap_array:
        		 %essid = ap_t[0]
		         %qual = ap_t[1]
        		 %encry = ap_t[2]
			<p style="width:400px;font-size:18px" align="left"><option class='icat-option' value='{{essid}}' encry='{{encry}}' ssid='{{essid}}'>{{essid + ' ,' + encry + ' (' + qual + '%)'}}</option></p>
			%end
			<option style="font-size:18px" selected="selected">Please Select Wifi</option>
		</select>
		<form name="form1" id="forms" style="display:none" >
		<p style="color:blue; font-size:20px"; align="left">Password</p>
		<p align="left"><input class="icat_input_high icat_color_bk" type="text" style="width:400px; height:30px; font-size:18px" placeholder="password" name="password" id="password">
		&nbsp&nbsp&nbsp<input type=checkbox name="save_password" id="save_password" value=1>save</p>
		</form>
		<br>
		<br>
		<div class="btn btn-block btn-primary" align="center" style="width:300px; font-size:16px; display:none" type="submit" name="butt1" id="butt1" onClick="password_connect();" >Submit
		</div>
	</fieldset>
     </fieldset>
    </div>
   </li>
  </ul>
 </div>
 <div >
     <fieldset class="container icat-fieldset-sub1" style="margin-top:330px">
	<fieldset>
		<p style="font-size:16px; font-weight:bold; color:blue" align="center">Dongle
		on<input class="icat_color_bk" type="radio" name="dongle" id="on" onClick="dongle_on();">
		off<input class="icat_color_bk" type="radio" name="dongle" id="off" onClick="dongle_off();">
		</p>
		</form>
		%import icatch_funcs
		%ret = icatch_funcs.dongle_exist()
		<p align="center" style="font-size:15px;">{{ret}}<p>
		%end
	</fieldset>
    </fieldset>
 </div>
</div>
%include('footer.tpl')
</body>
</html>
