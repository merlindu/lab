<!DOCTYPE html>
<html>
  <head>
    <title>home</title>
    %include('head.tpl')
  </head>

  <body>
    <div class='container'>

      %include('navi.tpl')

      <div class='icat-blk-round icat-blk-main icat-color-bk'>

        %import icatch_funcs
        
        <fieldset class='container icat-fieldset-main'>

          %hostname = icatch_funcs.uci_get('system.@system[0].hostname') or 'placeholder'
          <fieldset class='container icat-fieldset-sub1'>
            <legend>System</legend>
            <p><strong>Hostname: </strong>{{get('hostname','placeholder')}}</p>
            <p><strong>Firmware version: </strong>{{get('firm_ver','placeholder')}}</p>
          </fieldset>

          %netlist = icatch_funcs.get_net_info()
          %for net in netlist:
          <fieldset class='container icat-fieldset-sub1'>
            <legend>Network:{{net[0]}}</legend>
            <p><strong>HwAddr: </strong>{{net[1]}}</p>
            <p><strong>IP Address: </strong>{{net[2]}}</p>
            <p><strong>Broadcast: </strong>{{net[3]}}</p>
            <p><strong>Netmask: </strong>{{net[4]}}</p>
          </fieldset>
          %end

          <fieldset class='container icat-fieldset-sub1'>
            %wifi_info = icatch_funcs.get_wifi_info()
            <legend>Wireless</legend>
            <p><strong>SSID: </strong>{{wifi_info[1]}}</p>
            <p><strong>Mode: </strong>{{wifi_info[0]}}</p>
          </fieldset>
        </fieldset>
      <div>
	</div>
	<div style="width:100%;">
		<script>
			function goto_luci(){
				window.location.href =  "//" + document.domain + "/cgi-bin/luci";
			}
		</script>
		<p style="margin-top:80px;border-top:1px solid rgba(0,0,0,0.12);padding-top:10px;text-align:center;">
			<span>For advanced network configuration, go to </span>
			<a style="color:#00a1de;text-decoration:none;" href="javascript:goto_luci();">OpenWrt</a>
			<span>.</span>
		</p>
	</div>

    %include('footer.tpl')

  </body>

</html>
