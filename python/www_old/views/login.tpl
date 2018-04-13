<!DOCTYPE html>
<html>
  <head>
    <title>login iCatchtek</title>
    %include('head.tpl')
    <link href="/css/signin.css" rel="stylesheet">
    <script src="/js/md5.js"> </script>
    <script>
      function password_send() {
        var method = "post";
        var eventId = "icat_login";
        var data = "name=" + $("#inputAccount").val() + "&password=" + hex_md5( $("#inputPassword").val() );

        XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
          var jsonstring = xmlhttp.responseText;
          var json = eval( "("+jsonstring+")" );
          var login = json.login;
          if ( login == 0 )
          {
            $('#login_message').html('Username or password wrong!');
            $('#login_message').css('display', 'block');
            $('#inputAccount').val('');
            $('#inputPassword').val('');
            window.setTimeout( "$('#login_message').css('display', 'none');", 2000 );
          }
          else if( login == 1 )
          {

            $.cookie( 'icatch_auth', json.cookie, { expires: 0.08, path: '/'} );  //1.92hours
            $.cookie( 'icatch_session', json.session, { expires: 0.08, path: '/'} );  //1.92h

            $('#login_message').html( 'Loged in, current IP: ' + json.ip );
            $('#login_message').css('display', 'block');
            window.setTimeout( "window.location.href='/'",1500 );
          }
        });
        setTimeout( function(){}, 800 );
      }
    </script>
    <style type="text/css">
      body {
        padding-top: 40px;
        padding-bottom: 40px;
        background-color: #eee;
      }
      #login_message{display:none;text-align:center;color:red;margin-top:10px;}
    </style>
  </head>

  <body>
    <div class="container">
      <div class="icat-login-signin">
        <h2 class="text-center">iCatchtek Login</h2>
        <input class="form-control" type="text" id="inputAccount" style="margin-top:30px;" onkeypress="if(event.keyCode==13) password_send();" placeholder="account" required autofocus>
        <input class="form-control" type="password" id="inputPassword" style="margin-top:20px;"  onkeypress="if(event.keyCode==13) password_send();" placeholder="password">
        <button class="btn btn-lg btn-primary btn-block" type="submit" style="margin-top:40px;" onclick="password_send()">Sign in</button>
        <div>
          <p id="login_message"></p>
        </div>
      </div>
    </div> 

    %include('footer.tpl')
  </body>
</html>
