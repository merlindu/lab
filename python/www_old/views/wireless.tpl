<html>
  <head>
    <title>Wireless Setting</title>
    %include('head.tpl')
  </head>

<body>
  <div class="container">
    %include('navi.tpl')
    <div class="icat-blk-round icat-blk-main icat-color-bk" >
      <div style="overflow:hidden">
        <div class="icat-div-float icat-color-tab" id="table_mode_ap" onClick="submit_mode( this,'ap' );">
          AP mode
        </div>
        <div class="icat-div-float icat-color-tab" id="table_mode_sta" onClick="submit_mode( this,'sta' );">
          Station mode
        </div>

        <div style="clear:both"></div> <!-- 此div对于float布局很有必要，虽然看似不需要 -->
      </div>

      <div id="tab_content">
        </br></br>
        <p>Please select a wireles mode to dispose.</p>
      </div>
    </div>
  </div> <!-- div class="container"  end -->
  %include('footer.tpl')

  <script>
    function submit_mode( ele, mode ) {
      if( !$(ele).hasClass('icat-color-border-btm-selected') )
      {
        $('#table_mode_ap').removeClass('icat-color-border-btm-selected');
        $('#table_mode_sta').removeClass('icat-color-border-btm-selected');
        $(ele).addClass('icat-color-border-btm-selected');

        var method = "post";
        var eventId = "set_wifi_mode";
        var data = "mode=" + mode;

        XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
          $("#tab_content").html(xmlhttp.responseText);
        });
      }
    }
  </script>

  </body>

</html>