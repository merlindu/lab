<!DOCTYPE html>
<html>
  <head>
    %include('head.tpl')
    <script>
      if ( confirm('Are you sure to logout?') ) { 
          var method = 'post';
          var eventId = 'icat_logout';
          var data = '';

          XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
            if( xmlhttp.responseText == 'success' )
            {

              $.removeCookie( 'icatch_auth', { path: '/' } );
              $.removeCookie( 'icatch_session', { path: '/' } );
              window.location.href = '/';
            }
          });
      }
      else
      {
        window.history.back();
      }

    </script>
  </head>

  <body>
    %include('footer.tpl')
  </body>
</html>
