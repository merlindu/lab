<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <title>Overview</title>
  <style type="text/css">
    table thead tr th {
      font-size: 20px;
      padding: 3px 3px;
    }
    table tbody tr td {
      font-size: 15px;
      padding: 3px 3px;
    }
    table tbody tr td:first-child {
      font-weight: bold;
      width: 60%;
    }
    .card-panel {
      border-radius: 12px;
    }
  </style>
</head>
<body>
  %include('component/navigation.tpl')

  <div class="container">
    <div class="card-panel grey lighten-2">

      %from utils import uci, network, wireless
      %hostname = uci.get('system.@system[0].hostname') or 'placeholder'
      <div class="row">
        <div class="card-panel light-blue col s12 m10 offset-m1 l10 offset-l1 xl8 offset-xl2">
          <table>
            <thead>
              <tr><th class="orange-text text-accent-3">System</th><th></th></tr>
            </thead>
            <tbody>
              <tr><td>Hostname</td><td>{{get('hostname','placeholder')}}</td></tr>
              <tr><td>Firmware version</td> <td>{{get('firm_ver','placeholder')}}</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      %netlist = network.get_info()
      %for net in netlist:
      <div class="row">
        <div class="card-panel light-blue col s12 m10 offset-m1 l10 offset-l1 xl8 offset-xl2">
          <table>
            <thead>
              <tr><th class="orange-text text-accent-3">Network: {{net["ifname"]}}</th><th></th></tr>
            </thead>
            <tbody>
              <tr><td>HwAddr</td><td>{{net["hwaddr"]}}</td></tr>
              <tr><td>IP Address</td><td>{{net["ipaddr"]}}</td></tr>
              <tr><td>Broadcast</td><td>{{net["bcast"]}}</td></tr>
              <tr><td>Netmask</td><td>{{net["mask"]}}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
      %end

      %iwinfos = wireless.get_status()
      %for iwinfo in iwinfos:
      <div class="row">
        <div class="card-panel light-blue col s12 m10 offset-m1 l10 offset-l1 xl8 offset-xl2">
          <table>
            <thead>
              <tr><th class="orange-text text-accent-3">{{iwinfo["name"]}}</th><th></th></tr>
            </thead>
            <tbody>
              <tr><td>SSID</td><td>{{iwinfo["essid"]}}</td></tr>
              <tr><td>Mode</td><td>{{iwinfo["mode"]}}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
      %end

    </div>
  </div>

  %include('component/footer.tpl')
</body>
</html>
