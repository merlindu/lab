<!DOCTYPE html>
<html>
	<head>
		<title>Real Video</title>
		%include('head.tpl')
		<style>
			#vlcdiv{
				position: absolute;
				top: 13%;  left: 20%;
				width:60%; height:60%;
			}
	    </style>
		<script>
			$(document).ready(function(){
				var width = document.body.clientWidth * 0.6;
				var height = window.screen.availHeight * 0.6;
				
				var rtsp_domain = document.domain;
				//var rtsp_port = "554";
				//var vedio_url = "rtsp://" + rtsp_domain + ":" + rtsp_port + "/stream";
				var vedio_url = "rtsp://" + rtsp_domain + "/stream";
				var vlc = document.getElementById("vlc_plugin");	
					
				if (vlc) {	
					try {
						vlc.width = width;
						vlc.height = height;
						var itemId = vlc.playlist.add( vedio_url );
						vlc.playlist.playItem( itemId );
					} catch (err) {
						$("#vlcdiv").html("<p style='color:#ffffff'>VLC plugin is not supported by current browser!</p>");
						$("#vlcdiv").css("background-color", "black");	
					}
				} else {
					alert("getting VLC failed!");
				} 
				$('#real_url').html( vedio_url );
				$('#real_url').css( "color", "red" );
			});
		</script>
	</head>
	<body>
		%include('navi.tpl')
		<div id="vlcdiv">
			<table>
				<tr>
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
				</tr>
				<tr>
					<td id="real_url"></td>
				</tr>
			</table>
		</div>
	</body>
</html>

