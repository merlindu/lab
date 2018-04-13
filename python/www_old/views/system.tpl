<html>
  <head>
    %include('head.tpl')
    <title>System</title>
  </head>

  <body>
    <div class="container">
      %include('navi.tpl')
      <div class="icat-blk-round icat-blk-main icat-color-bk" >
        %if( defined('account') ):
        %account = account or 'unknown'
        %end

        <div style='margin-left:10px;padding-top:10px;'>

          <div style='margin-bottom:10px;'>
            <span style='max-width:100px;'>Current Account:&nbsp;&nbsp;<strong>{{account}}&nbsp;&nbsp;</strong></span>
            </br>
            <input class='btn icat-color-tab' style='margin-top:10px;' type="button" id='start_change' onclick="start_change( this )" value="Change Password">
          </div>

          <div style='display:none;' id="id_pwd_content_blk">
            <div style='display:block;'>
              <span>Current Password:&nbsp;&nbsp;</span>
              <input class="icat_input_high icat-color-bk" type="password" style='max-width: 230px;' id='pwd_old' maxlength="20">
              </br>
              </br>
            </div>
            <span>New Password:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
            <input class="icat_input_high icat-color-bk" type="password" style='max-width: 230px;' id='pwd_new' maxlength="20">
            </br>
            </br>
            <span>Confirm Password:&nbsp;&nbsp;</span>
            <input class="icat_input_high icat-color-bk" type="password" style='max-width: 230px;' id='pwd_new_cfm' maxlength="20">
            </br>
            <input class='btn icat-color-tab' style='margin-top:10px;' type="button"  onclick="change_pwd()" value="Submit">
          </div>
        </div>
      </div>
    </div>
    %include('footer.tpl')
    <script src="/js/md5.js"> </script>
    <script>

       function start_change( ele ) 
       {
          $('#id_pwd_content_blk').css('display','block');
          $(ele ).css('display','none');
        }

        function change_pwd() 
        {
          var account = '{{account}}';
          var old = $('#pwd_old').val();
          var new1 = $('#pwd_new').val();
          var new2 = $('#pwd_new_cfm').val();

          var method = "post";
          var eventId = "checkpassword";
          var data = "account=" + account + "&password=" + hex_md5( old );

          if( new1 == new2 && new1 != '' )
          {
            XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
                var checkOK = xmlhttp.responseText;
                if( checkOK != 1 )
                {
                  alert("Input error, please check/refresh and try again!!");
                }
                else
                {
                  $('#start_change').css('display','block');
                  $('#id_pwd_content_blk').css('display','none');

                  eventId = "account_setting";
                  data = "account=" + account + "&pwd=" + new1;
                  XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
                    var status = xmlhttp.responseText;
                    alert(status);
                  });

                }
            });
          }
          else
          {
            alert("Input error, please check and try again!!");
          }
          $('#pwd_old').val('');
          $('#pwd_new').val('');
          $('#pwd_new_cfm').val('');
        }
    </script>
  </body>

</html>