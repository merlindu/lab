<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <link href="/css/video-js-5.20.4.min.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <link href="/css/media_real.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <title>Real Media</title>
</head>
<body>
  %include('component/navigation.tpl')

  <div class="container"><div class="section">
    <div class="row">

      <div class="col s12 realtype">
        <div><p><label>
          <input class="with-gap" name="real_type" type="radio" value="flv" checked />
          <span>HTTP</span>
        </label></p></div>
        <div><p><label>
          <input class="with-gap" name="real_type" type="radio" value="rtmp"/>
          <span>RTMP</span>
        </label></p></div>
        <div><p><label>
          <input class="with-gap" name="real_type" type="radio" value="rtsp"/>
          <span>RTSP</span>
        </label></p></div>
      </div>

      <div id="real_content"></div>

    </div>
  </div></div>


  %include('component/footer.tpl')
<!-- flv-http content>>>>>> -->
  <script src="/js/flv-1.4.0.min.js"></script>

  <script type="text/html" id="real_content_flv">
    <div class="col s12">
      <div class="flv-container"><div>
        <video id="flv_video" class="centeredVideo" controls autoplay>
          Your browser is too old which doesn't support HTML5 video.
        </video>
      </div></div>
    </div>
    <div class="col s6 control">
      <button class="waves-effect waves-light btn" onclick="flv_load()">Start</button>
    </div>
    <div class="col s6 control">
      <button class="waves-effect waves-light btn" onclick="flv_destroy()">Stop</button>
    </div>
    <div class="col s12">
      <textarea name="logcatbox" class="logcatBox" rows="10" readonly></textarea>
    </div>
  </script>

  <script>
    var flv_player = null;
    function flv_load()
    {
      console.log('isSupported: ' + flvjs.isSupported());
      if(flvjs.isSupported() != true) {
        var check1 = window.MediaSource;
        var check2 = false;
        if( check1 && window.MediaSource.isTypeSupported('video/mp4; codec="avc1.640028,mp4a.40.5"') ){
          check2 = true;
        }
        alert("Device not support flv.js. window.MediaSource:" + check1
          + ".\nwindow.MediaSource.isTypeSupported('video/mp4; codecs=\"avc1.640028,mp4a.40.5\"'):"
          + check2);
      }

      var mediaDataSource = {
        type: 'flv',
        isLive: true,
        withCredentials: false,
        hasAudio: true,
        hasVideo: true,
        url: "http://" + document.domain + ":8888/live/stream"
      };
      console.log('MediaDataSource', mediaDataSource);

      if(flv_player != null){
        flv_player.unload();
        flv_player.detachMediaElement();
        flv_player.destroy();
        flv_player = null;
      }

      flv_player = flvjs.createPlayer(mediaDataSource, {
        lazyLoadMaxDuration: 3*60,
        enableStashBuffer: false,
        fixAudioTimestampGap: false,
        autoCleanupSourceBuffer: true,
        isLive: true,
      });

      flv_player.attachMediaElement( document.getElementById('flv_video') );
      flv_player.load();
      flv_player.play();
    }
    function flv_destroy()
    {
      try{
        flv_player.pause();
        flv_player.unload();
        flv_player.detachMediaElement();
        flv_player.destroy();
        flv_player = null;
      }catch(e){
      }
    }
  </script>
<!-- flv-http content<<<<<< -->

<!-- rtmp content>>>>>> -->
  <script src="/js/videojs-admin.js"></script>
  <script src="/js/videojs-5.20.4.min.js"></script>
  <script src="/js/videojs-ie8-5.20.4.min.js"></script>
  <script src="/js/sfobject-v2.2.js"></script>
  <script type="text/html" id="real_content_rtmp">
    <div class="col s12 center rtmp">
      <!-- div scope: rtmp-video>>>>>> -->
<!--       <div class="col s12 m6">
        <div class="col s12 rtmp-format">
          <div><p><label>
            <span>Format</span>
          </label></p></div>
          <div><p><label>
            <input class="with-gap" name="video_format" type="radio" value="H264"/>
            <span>H264</span>
          </label></p></div>
          <div><p><label>
            <input class="with-gap" name="video_format" type="radio" value="YUYV"/>
            <span>YUYV</span>
          </label></p></div>
        </div>

        <div class="col s12 rtmp-resolution">
        </div>
      </div> -->
      <!-- div scope: rtmp-video<<<<<< -->

      <!-- div scope: rtmp-audio>>>>>> -->
<!--       <div class="col s12 m6">
      </div> -->
      <!-- div scope: rtmp-audio<<<<<< -->

<!--       <div class="col s12 left">
        url:xxxs
      </div>
      <div class="col s12 left">
        play time:xxxs
      </div> -->

      <div class="col s12 rtmp-player-wrapper">
        <div class="rtmp-player black center">
          <video id="rtmp_video" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="auto">
          </video>
        </div>
      </div>
      <div class="rtmp-control">
        <div class="col s6 m3"><button class="waves-effect waves-light btn">Play</button></div>
        <div class="col s6 m3"><button class="waves-effect waves-light btn">Pause</button></div>
        <div class="col s6 m3"><button class="waves-effect waves-light btn">Stop</button></div>
        <div class="col s6 m3"><button class="waves-effect waves-light btn">Restart</button></div>
      </div>
    </div>
  </script>

  <script>
    var videojs_player = null;
    function init_videojs_player()
    {
      videojs.options.flash.swf = "/media/video-js.swf"
      var width = String( $(".rtmp-player").width() );
      videojs_player = videojs("rtmp_video", {
        autoplay: false,
        loop: true,
        fluid: true,
        width: width,
        controlBar: {
          captionsButton: false,
          chaptersButton: false,
          playbackRateMenuButton: false,
          LiveDisplay: true,
          subtitlesButton: false,
          remainingTimeDisplay: true,
          progressControl: true,
          volumeMenuButton: {
            inline: false,
            vertical: true
          },
          fullscreenToggle: true
        }
      }, null);
    }
    function dispose_videojs_player()
    {
      if($("#rtmp_video").length>0){
        try{
          videojs_player.dispose();
          videojs_player = null;
        }catch(err){
        }
      }
    }
  </script>
<!-- rtmp content<<<<<< -->

<!-- rtsp content>>>>>> -->
  <script type="text/html" id="real_content_rtsp">
    <div id="vlcdiv" class="col s12 center">
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
  </script>
<!-- rtsp content<<<<<< -->

<!-- main control>>>>>> -->
  <script src="/js/xmlhttp.min.js"></script>
  <script>
    var rtmp_player_inited = false;
    var real_content_ready = {
      flv: function(){
        $("#real_content").html( $("#real_content_flv").html() );
        M.updateTextFields();
        flvjs.LoggingControl.addLogListener(function(type, str){
          $("textarea").val( $("textarea").val() + str + '\n');
          $("textarea").scrollTop($("textarea").scrollHeight);
        });
        document.addEventListener('DOMContentLoaded', function(){
          flv_load();
        });
      },
      rtmp: function(){
        $("#real_content").html( $("#real_content_rtmp").html() );
        init_videojs_player();

        videojs_player.ready(function(){
          this.src({
            type: "rtmp/flv",
            //src: "rtmp://192.168.1.104/live/stream"
            //src: "rtmp://live.hkstv.hk.lxdns.com/live/hks"
            src: "rtmp://" + document.domain + "/live/stream"
          });
          if(rtmp_player_inited==false){
            this.load();
            this.play();
            rtmp_player_inited = true;
          }
        });

        $(".rtmp-control div button").click(function(){
          var cmd = $(this).text().toLowerCase();
          if(cmd=="stop"){
            dispose_videojs_player();
            real_content_ready.rtmp();
            return;
          }else if(cmd=="restart"){
            dispose_videojs_player();
            rtmp_player_inited = false;
            real_content_ready.rtmp();
            return;
          }
          eval( "videojs_player." + cmd + "()" );
        });
      },
      rtsp: function(){
        $("#real_content").html( $("#real_content_rtsp").html() );
        var rtsp_url = "rtsp://" + document.domain + "/stream";
        var vlc = document.getElementById("vlc_plugin");
        var width = $("#vlcdiv").width();
        var height = width*0.5625; //0.5625=9/16
        $("#vlcdiv").height(height);

        $(window).resize(function(){
          width = $("#vlcdiv").width();
          height = width*0.5625;
          $("#vlcdiv").height(height);
          $("#vlcdiv p").css("line-height", height + "px");
          try{
            vlc.width = width;
            vlc.height = height;
          }catch(err){
          }
        });
        if(vlc){
          try{
            vlc.width = width;
            vlc.height = height;
            var itemId = vlc.playlist.add( rtsp_url );
            vlc.playlist.playItem( itemId );
          }catch(err){
            $("#vlcdiv").html("<p>Browser doesn't support VLC plugin!</p>");
            $("#vlcdiv").css("background-color", "black");
            $("#vlcdiv").css("color", "white");
            $("#vlcdiv p").css("line-height", height + "px");
          }
        }else{
          alert("getting VLC failed!");
        }
        $('#real_url').html( rtsp_url );
        $('#real_url').css( "color", "red" );
      }
    };

    var real_content_exit = {
      flv: function(){
        flv_destroy();
      },
      rtmp: function(){
        dispose_videojs_player();
      },
      rtsp: function(){
      }
    };

    var current_type = "none";
    function change_real_type(type){
      if(type!="flv" && type!="rtmp" && type!="rtsp"){
        alert("real type error: " + type);
        return;
      }
      if(current_type==type) return;
      if(current_type!="none")
        eval("real_content_exit" + "." + current_type + "()");

      rtmp_player_inited = false;
      eval("real_content_ready" + "." + type + "()");
      current_type = type;
    }

    $(document).ready(function(){
      change_real_type($("input[type=radio][name=real_type]").val());
      $("input[type=radio][name=real_type]").change(function(){
        change_real_type(this.value);
      });
    });
  </script>
<!-- main control<<<<<< -->
</body>
</html>
