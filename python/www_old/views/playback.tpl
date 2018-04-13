<!DOCTYPE html>
<html>
	 <head>
	    <title>Play back</title>
	    %include('head.tpl')
		<link href="/css/tcal.css" rel="stylesheet">
		<script src="/js/tcal.js"></script> 
	    <style type="text/css">
	       html{ height:100%; overflow:hidden;}
	    	body{ height:100%; overflow:auto;}
	        #layer_mask_gray{ 
	        	display: none;  position: absolute;  top: 0%;  left: 0%;  width: 100%;  height: 100%;  
	        	background-color: black;  z-index:1001;  
	        	/* older safari/Chrome browsers */
	        	-webkit-opacity: 0.6; 

	        	/* Netscape and Older than Firefox 0.9 */
	        	-moz-opacity: 0.6; 

	        	/* Safari 1.x (pre WebKit!) old khtml core Safari*/  
	        	-khtml-opacity: 0.6;  

	        	/* IE9 + etc...modern browsers */ 
	        	opacity:.60;  

	        	/* IE 4-9 */ 
	        	filter: alpha(opacity=60);

	        	/*This works in IE 8 & 9 too*/  
    			-ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=60)";  

    			/*IE4-IE9*/  
    			filter:progid:DXImageTransform.Microsoft.Alpha(Opacity=60);
	        }
	        #global_layer_top{
				display: none; 
				position: absolute;
				top: 13%;  left: 20%;
				background-color: black;
				z-index:1002;
				overflow: auto;
			}
	    </style>
	    <script>
			function show_play_frame( id, video ){
				var width = document.body.clientWidth *0.6;
				var height = document.body.clientHeight * 0.6;
				
				$("#global_layer_top").css( "width", width + 'px' );
				//$("#global_layer_top").css( "height", height + 50 + 'px' );
				
				$("#info_div").css( "height", '50px' );
				var rtsp_domain = document.domain;
				//var rtsp_domain = "172.28.53.178";
				var rtsp_port = "554";
				var rtsp_file = video;
				var vedio_url = "rtsp://" + rtsp_domain + ":" + rtsp_port + rtsp_file;
    			var vlc = document.getElementById("vlc_plugin");
    			if(vlc){	
					$('#file_info').html( vedio_url);
					$("#layer_mask_gray").css( "display", "block" );
					$("#global_layer_top").css( "display", "block" );
            		window.onmousewheel = function(){ return false }; 
					
					try {
						vlc.width = width;
						vlc.height = height;
						var itemId = vlc.playlist.add( vedio_url );
						vlc.playlist.playItem( itemId );
					} catch (err) {
						$("#info_div div p").html("VLC plugin is not supported by current browser!");
					}
				}else{
					alert("getting VLC failed!");
				} 
			}

			function hide_play_frame() {
				var vlc = document.getElementById( "vlc_plugin" );
				if(vlc){
					try {
						vlc.playlist.stop();
					} catch (err) {
					}
			   	}else{
	            	alert("getting VLC failed!");
	            } 
				$("#layer_mask_gray").css( "display", "none" );
				$("#global_layer_top").css( "display", "none" );
	            window.onmousewheel=function(){ return true }; 
        	}
			
			function on_day_selected(year, month, day){
				if( !$(":checkbox").is(":checked") )
					return;
				var method = "post";
				var eventId = "calendarPOST";
				var data = "year=" + year + "&month=" + month + "&day=" + day;

				XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
					//var jsonstring = xmlhttp.responseText;
					$("#gallery_main").html( xmlhttp.responseText );
				});
			}
			function re_scan_all_media(){
				var method = "post";
				var eventId = "re_scan_all_media";
				var data = "status=0";

				XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
					alert(xmlhttp.responseText);
				});
			}
			function filter_switch(){
				if( $(":checkbox").is(":checked") ){
					$(":text").removeAttr("disabled");
					$("#gallery_main").html("");
				}else{
					f_tcalCancel();
					$(":text").attr("disabled","disabled");
					var method = "post";
					var eventId = "show_all_media";
					var data = "status=0";
					XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
						$("#gallery_main").html( xmlhttp.responseText );
					});
				}
			}
			$(document).ready(function(){
				$(":checkbox").bind({
					click:function () {
						filter_switch();
					}
				});
				
				$(":button.scan").bind({
					click:function () {
						re_scan_all_media();
					}
				});

				filter_switch();
			});
	    </script>
	</head>

	<body>
		%include('navi.tpl')
		%#include('calendar.tpl')
		
		<div class="container">
				<input class="form-control tcal col-sm-6 col-md-3" style="width:auto;margin-right:3px" type="text" name="date"  value=""/>
				<input class="col-sm-6 col-md-3" style="width:auto;height:34px;margin-right:10px" type="checkbox"/>
				<input class="btn btn-primary btn-block col-sm-6 col-md-3 scan" style="width:auto;" type="button"  value="Scan media"/>
				<br/>
				<br/>
		</div>

		<div id="gallery_main" style="padding-bottom: 50px;">
		</div> <!-- id="gallery_main" -->	

		<div> <!-- play window start-->
		    <div id="layer_mask_gray"></div> <!-- do not delete this div, or player will failed!!!-->

		    <div id="global_layer_top">
				<table>
					<tr>
						<td>
							<div id="info_div">
								<div style="float:left;width:95%;word-break:break-all; word-wrap:break-word;">
									<p style="color:white;left:100px" id="file_info"></p>
								</div>
								<button class='btn btn-primary' style="float:left;width:5%" type='button' title='Click to close play window.' onclick='hide_play_frame();'>x</button>
							</div >
						</td>
					</tr>
					<tr style="vertical-align:bottom" >
						<td>
							<!--[if IE]>
								<object type='application/x-vlc-plugin' id='vlc_plugin' events='True'
									classid='clsid:9BE31822-FDAD-461B-AD51-BE1D1C159921' 
									codebase='http://downloads.videolan.org/pub/videolan/vlc/latest/win32/axvlc.cab'
									width="720" height="540">
									<param name='mrl' value='' />
									<param name='volume' value='50' />
									<param name='autoplay' value='false' />
									<param name='loop' value='false' />
									<param name='fullscreen' value='true' />
								</object>
							<![endif]-->
							<!--[if !IE]><!-->
								<object type='application/x-vlc-plugin' id='vlc_plugin' events='True' width="720" height="540">
									<param name='mrl' value='' />
									<param name='volume' value='50' />
									<param name='autoplay' value='true' />
									<param name='loop' value='false' />
									<param name='fullscreen' value='true' />
								</object>
							<!--<![endif]-->
						</td>
					</tr>
				</table>
			</div> <!--  div,id="global_layer_top" -->
		</div> <!-- play window end-->
		<div style="padding-bottom: 30px;"></div>
		%include('footer.tpl')
	</body>
</html>
