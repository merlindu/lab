<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title> Error 404 </title>
		<style type="text/css">
		body{margin:8% auto 0;max-width: 550px; min-height: 200px;padding:10px;font-family: Verdana,Arial,Helvetica,sans-serif;font-size:14px;}p{color:#555;margin:10px 10px;}img {border:0px;}.d{color:#404040;}
		</style>
	</head>
	<body>
	<script type="text/javascript">
	function isIFrameSelf()
	{
		try
		{
			if( window.top == window )
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		catch(e)
		{
			return true;
		}
	}
	function toHome()
	{ 
		if( !isIFrameSelf() )
		{ 
			window.location.href = "/";
		}
	}
	window.setTimeout( "toHome()",5000 );
	</script>

	<table border=0 cellpadding=0 cellspacing=0 >
	 <tr><td height=134></td></tr>
	</table>
	<table width=544 height=157 border=0 cellpadding=0 cellspacing=0 align=center>
	  <tr valign=middle align=middle>
		<td >
			<table border=0 cellpadding=0 cellspacing=0 >
				<tr>
					<td><strong>We couldn't find the page you requested. <br/>It will automatically back to home page in 5 seconds!</strong></td>
				</tr>
				<tr>
					<td><strong><a href="/"><br/>Back to Home Page</a></strong></td>
				</tr>
			</table>
		</td>
	  </tr>
	</table>
	<br>
  </body>
</html>