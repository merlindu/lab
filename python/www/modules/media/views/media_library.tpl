<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <link href="/css/video-js-5.20.4.min.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <link href="/css/media_tcal.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <link href="/css/media_library.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <title>Library</title>
</head>
<body>
  %include('component/navigation.tpl')
  <div id="top"></div>
  <div class="container"><div class="section"><div class="row">
    <div class="col s12 filter"><div class="container"><div class="row">
      <div class="col s3 m2 filter-checkbox"><div class="input-field"><p><label>
        <input type="checkbox" class="filled-in" checked/>
        <span>All</span>
      </label></p></div></div>
      <div class="col s6 m4 offset-m2"><div class="input-field filter-cal">
        <input class="tcal" type="text" name="date">
      </div></div>
      <div class="col s3 m4 filter-rescan"><div class="input-field">
        <button class="waves-effect waves-light btn">Scan Files</button>
      </div></div>
    </div></div></div>

    <div id="player"></div>
    <script type="text/html" id="player_html">
      <div class="col s12 m8 offset-m2"><div class="col s12 rtmp-player-wrapper">
        <div class="rtmp-player black center">
          <video id="rtmp_video" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="auto">
          </video>
        </div>
        <div class="col s12 red-text" id="rtmp_url"></div>
      </div></div>
    </script>

    <div class="col s12 section-devider"></div>
    <div class="library-wrapper"></div>

  </div></div></div>

  %include('component/footer.tpl')
  <script src="/js/xmlhttp.min.js"></script>
  <script src="/js/media_tcal.js"></script>
  <script src="/js/videojs-admin.js"></script>
  <script src="/js/videojs-5.20.4.min.js"></script>
  <script src="/js/videojs-ie8-5.20.4.min.js"></script>
  <script src="/js/sfobject-v2.2.js"></script>
  <script>
    var videojs_player = null;
    function init_videojs_player()
    {
      videojs.options.flash.swf = "/media/video-js.swf"
      var width = String( $(".rtmp-player").width() );
      videojs_player = videojs("rtmp_video", {
        autoplay: false,
        loop: false,
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
  <script>
    function play_file(path, name){
      location.href = "#top"; 
      var file = path + "/" + name;
      var url = "rtmp://" + document.domain + file;
      dispose_videojs_player();
      $("#player").html( $("#player_html").html() );
      $("#rtmp_url").html( '<p class="flow-text">' + url + '</p>');
      init_videojs_player();
      videojs_player.ready(function(){
        this.src({
          type: "rtmp/flv",
          //src: "rtmp://192.168.1.104/live/stream"
          //src: "rtmp://live.hkstv.hk.lxdns.com/live/hks"
          src: url
        });
        this.load();
        this.play();
      });
    }
    function update_library_section(items)
    {
      $(".library-wrapper").empty();
        for(var i=0; i<items.length; i++){
          var text = 
            '<div class="col s6 m3">' +
              '<div class="card">' +
                '<div class="card-image">' +
                  '<a href="javascript:void(0)" onclick="play_file(this.dataset.path, this.dataset.name);" id="' + i + '" data-name="' + items[i].name +
                      '" data-path="' + items[i].path +'">'+
                    '<img src="/images/media_thumb.jpg">' +
                  '</a>' +
                  '<span class="card-title library-name" title="' + items[i].name +'">' + 
                    items[i].name + 
                  '</span>' +
                '</div>' +
                '<div class="card-content center">' +
                  '<p>' +
                    items[i].date +
                  '</p>' +
                '</div>' +
              '</div>' +
            '</div>';
          $(".library-wrapper").append(text);
        }
    }
    function update_gallery_by_date(year, month, day){
      var eventId = "update_gallery_by_date";
      var data = "year=" + year + "&month=" + month + "&day=" + day;
      XMLHttp.sendRequest( "/media/library", "post", eventId, data, function(xmlhttp){
        update_library_section( eval(xmlhttp.responseText) );
      });
    }
    function rescan_all_files(){
      XMLHttp.sendRequest( "/media/library", "post","rescan_all_files", "status=0", function(xmlhttp){
        var status = eval(xmlhttp.responseText);
        alert(status!=-1?"Scan media file completed!":"Scan media file failed!")
      });
    }
    function reinit_filter(){
      if( $(":checkbox").is(":checked") ){
        //scan all files
        f_tcalCancel();
        $(":text").attr("disabled","disabled");
        XMLHttp.sendRequest( "/media/library", "post", "show_all_media", "status=0", function(xmlhttp){
          update_library_section( eval(xmlhttp.responseText) );
        });
      }else{
        $(":text").removeAttr("disabled");
      }
    }

    $(document).ready(function(){
      M.updateTextFields();
      reinit_filter();
      $(".filter button").click(rescan_all_files);

      $(":checkbox").click(function(){
        reinit_filter();
      });
    });
  </script>
</body>
</html>
