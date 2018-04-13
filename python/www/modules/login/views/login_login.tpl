<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <title>Login</title>
  <style type="text/css">
    button {
      width: 100%;
    }
    .row {
      max-width: 800px;
    }
  </style>
</head>
<body>
  %include('component/navigation.tpl')

  <div class="container"><div class="section"><div class="row">
    <div class="col s10 offset-s1 m6 offset-m3">
      <h3 class="center">iCatch Login</h3>
      <div class="section"></div>
      <div class="input-field col s12">
        <i class="material-icons prefix">account_box</i>
        <input id="inputAccount" type="text" class="validate" onkeypress="if(event.keyCode==13) password_send();" required autofocus>
        <label for="inputAccount">Account</label>
      </div>

      <div class="input-field col s12">
        <i class="material-icons prefix">lock</i>
        <input id="inputPassword" type="password" class="validate" onkeypress="if(event.keyCode==13) password_send();" required autofocus>
        <label for="inputPassword">Password</label>
      </div>
      <div class="col s12">
        <button class="waves-effect waves-light btn-large" type="submit" name="action" onclick="password_send()">Sign in</button>
      </div>
      <div class="col s12">
        <p id="login_message" class="center red-text text-accent-4"></p>
      </div>
    </div>
  </div></div></div>
  <br><br>

  %include('component/footer.tpl')
  <script src="/js/jquery.cookie.js"></script>
  <script src="/js/xmlhttp.min.js"></script>
  <script src="/js/md5.min.js"> </script>
  <script>
      function password_send(){
      var data = "name=" + $("#inputAccount").val() + "&password=" 
                  + hex_md5( $("#inputPassword").val() );
      XMLHttp.sendRequest( "login/login", "post", "login_login", data, function(xmlhttp){
        var json = eval( "("+xmlhttp.responseText+")" );
        var login = json.login;
        if ( login == 0 ){
          $('#login_message').html('Username or password wrong!');
          $('#login_message').css('display', 'block');
          $('#inputAccount').val('');
          $('#inputPassword').val('');
          window.setTimeout( "$('#login_message').css('display', 'none');", 2000 );
        }else if( login == 1 ){
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
</body>
</html>
