<HTML>     
<HEAD> 
	 %include('head.tpl')
<TITLE>Dongle Set</TITLE>      
</HEAD>    
<BODY>
<h3 style="text-align:center">3G/4G Dongle Network Set </h3>
<div class='container'>
	 %include('navi.tpl')
          <span>* </span>
<div class='btn btn-lg btn-primary icat-btn icat-color-tab' style='width:30%;margin-left:50px;max-width:100px;' id='apply' onclick="getinf();">Connect
	</div>
	 <br>
   	 <br>
          <span>* </span>
<div class='btn btn-lg btn-primary icat-btn icat-color-tab' style='width:30%;margin-left:50px;max-width:100px;' id='break_off' onclick="break_off();">Break	
	</div>
	</div>
	 %include('footer.tpl')
<script language="javascript" type="text/javascript"> 
function tiaozhuan()
{
	window.location.href='/dongle_info';
}
</script>

<script type="text/javascript">
function break_off()
{
	var test = 'ok';
	var method = "post";
	var eventID = "dongle_break";
	var data = "test=" + test;
	XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
		var checkOK = xmlhttp.responseText;
		alert(checkOK);
	});
}
</script>

<script type="text/javascript">
function getinf()
{
	//alert("hello");
	var modem = 'connect';
	
	var method = "post";
	var eventID = "dongle_setting";
	var data ="modem=" + modem;
	
	alert("connecting,plesae wait for a moment!");
	XMLHttp.sendRequest( method, eventID, data, function(xmlhttp){
		var checkOK = xmlhttp.responseText;
    if( checkOK == "chat success" )
   	{
			alert("chat success!")
			tiaozhuan();
		}
		else if(checkOK == "chat failed")
		{
			alert("chat failed,repeat select and try again!")
		}
		else if(checkOK == "chat already connect")
		{
			alert("chat already connect!")
		}
		else if(checkOK == "usb device unrecognizable")
		{
			alert("No devicds available!")
		}
		else if(checkOK == "no device access")
		{
			alert("No devicd access!")
		}
		else
		{
			alert("Input error, please check/refresh and try again!!");
		}
	});
}

</script>
</BODY>   
</HTML>
