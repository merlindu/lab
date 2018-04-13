<!DOCTYPE html>
<html>
  <head>
    <title>state</title>
    %include('head.tpl')
  </head>
	<h2 style="text-align:center">Network Information</h2>
	<meta http-equiv="refresh" content="30">
 <body>
<br>
<style type="text/css">
table.hovertable {
	font-family: verdana,arial,sans-serif;
	font-size:11px;
	color:#333333;
	border-color: #999999;
	border-collapse: collapse;
}
table.hovertable th {
	background-color:#c3dde0;
	padding: 8px;
	border-style: solid;
	border-color: #a9c6c9;
}
table.hovertable tr {
	background-color:#d4e3e5;
}
table.hovertable td {
	padding: 8px;
	border-style: solid;
	border-color: #a9c6c9;
}
</style>
    <div class='container' align="center">
      %include('navi.tpl')
		<table class="hovertable" style="border-collapse:collapse;empty-cells:show" width="80%" height="100px">
        %import icatch_funcs
	%import commands
		%wanname = icatch_funcs.network_info1() 
		%mode = icatch_funcs.find_mode()
		%ssid = commands.getoutput("iwconfig wlan0 | grep 'ESSID' | awk '{print $4'} | awk -F: '{print $2}'")
		%if wanname == '':
			%Addr=''
			%Bcast=''
			%Netmask=''
		%else:
			%waninfo = icatch_funcs.get_wan_info()
			%Addr = waninfo.split()[1].split(':')[1]	
			%Bcast = waninfo.split()[2].split(':')[1]
			%Netmask = waninfo.split()[3].split(':')[1]
		%end
		<tr>
			<th>Mode</th><td>{{mode}}</td><th>SSID</th><td>{{ssid}}</td>
		</tr>
		<tr>
			<th>Wan</th><th>IP</th><th>Bcast</th><th>Netmask</th>
		</tr>
		<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
			<td>{{wanname}}</td><td>{{Addr}}</td><td>{{Bcast}}</td><td>{{Netmask}}</td>
		</tr>

		%lanname = icatch_funcs.network_info2()
		%if lanname =='no':
			%lanname =''
			%Addr1=''
			%Bcast1=''
			%Netmask1=''
		%else:
			%laninfo = icatch_funcs.get_lan_info()
			%Addr1 = laninfo.split()[1].split(':')[1]
			%Bcast1 = laninfo.split()[2].split(':')[1]
			%Netmask1 = laninfo.split()[3].split(':')[1]
		%end
		<tr>	
			<th>Lan</th><th>IP</th><th>Bcast</th><th>Netmask</th>
		</tr>
		<tr onmouseover="this.style.backgroundColor='#ffff66';" onmouseout="this.style.backgroundColor='#d4e3e5';">
			<td>{{lanname}}</td><td>{{Addr1}}</td><td>{{Bcast1}}</td><td>{{Netmask1}}</td>
		</tr>
		</table>
	 %end
      <div>
    </div>
    %include('footer.tpl')
  </body>
</html>
