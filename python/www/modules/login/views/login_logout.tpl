<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <title>Logout</title>
</head>
  <script src="/js/jquery-1.12.3.min.js"></script>
  <script src="/js/jquery.cookie.js"></script>
  <script src="/js/xmlhttp.min.js"></script>
  <script>
    $(document).ready(function(){
      if( confirm('Are you sure to logout?') ){ 
          XMLHttp.sendRequest( "login/logout", "post", "login_logout", "", function(xmlhttp){
            if(xmlhttp.responseText == 'success'){
              $.removeCookie( 'icatch_auth', { path: '/' } );
              $.removeCookie( 'icatch_session', { path: '/' } );
              window.location.href = '/';
            }
          });
      }else{
        window.history.back();
      }
    });
  </script>
<body>
</body>
</html>
