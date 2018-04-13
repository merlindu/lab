<!DOCTYPE html>
<html lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0"/>
  <title>page not found</title>
  <link rel="icon" type="image/ico" href="/images/favicon.ico">
  <style type="text/css">
    body{
      margin: 8% auto 0;
      max-width: 550px;
      min-height: 200px;
      padding: 10px;
      font-family: Verdana,Arial,Helvetica,sans-serif;
      font-size: 14px;
    }
  </style>
  <script type="text/javascript">
      function isIFrameSelf(){
        try{
          if(window.top==window) return false;
          return true;
        }catch(e){
          return true;
        }
      }
      function toHome(){ 
        if(!isIFrameSelf()){ 
          window.location.href = "/";
        }
      }
      window.onload = function(){
        window.setTimeout("toHome()", 5000);
      };
  </script>
</head>
<body>
  <table border=0 cellpadding=0 cellspacing=0 ><tr><td height=134></td></tr></table>
  <table width=544 height=157 border=0 cellpadding=0 cellspacing=0 align=center>
    <tr valign=middle align=middle><td>
      <table border=0 cellpadding=0 cellspacing=0 >
        <tr>
          <td><h1>404 NOT FOUND</h1><strong>Hmm, we couldn't find what you're looking for.</strong></td>
        </tr>
        <tr>
          <td><strong><a href="/"><br/>Go back to home page</a></strong></td>
        </tr>
      </table>
    </td></tr>
  </table>
  <br>
</body>
</html>
