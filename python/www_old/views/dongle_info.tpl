<!DOCTYPE html>
<html>
  <head>
    <title>home</title>
    %include('head.tpl')
  </head>
	<h3 style="text-align:center">Network Information</h3>
	<meta http-equiv="refresh" content="30">
 <body>
    <div class='container'>
      %include('navi.tpl')
      <div class='icat-blk-round icat-blk-main icat-color-bk'>
        %import icatch_funcs
        <fieldset class='container icat-fieldset-main'>
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
	 %netlist1 = icatch_funcs.get_net1_info()
	 %for net1 in netlist1:
	  <fieldset class='container icat-fieldset-sub1'>
	    <legend>Network:{{net1[0]}}</legend>
            <p><strong>IP Address: </strong>{{net1[1]}}</p>
            <p><strong>P-t-P: </strong>{{net1[2]}}</p>
            <p><strong>Netmask: </strong>{{net1[3]}}</p>
 	    <p><strong>Recvice bytes: </strong>{{net1[4]}} b</p>
	    <p><strong>Translate bytes: </strong>{{net1[5]}} b</p>
          </fieldset>
          </fieldset>
	  %end
        </fieldset>
      <div>
    </div>
	<div class='btn btn-lg btn-primary icat-btn icat-color-tab' style='width:30%;margin-left:200px;max-width: 100px;' id='submit_lan_args' onclick='history.go(-1);'>return 
	</div>
    %include('footer.tpl')
  </body>
</html>
