<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <title>Network</title>
  <style>
    .tab-content {
      padding-top: 20px !important;
      padding-bottom: 20px !important;
      border-bottom-right-radius: 10px;
      border-bottom-left-radius: 10px;
    }
    button {
      width: 100%;
      text-transform: capitalize !important;
    }
    .section {
      padding-top: 30px !important;
      padding-bottom: 30px !important;
    }
    html {
      min-width: 350px;
    }
    h5 {
      font-family: verdana !important;
      padding-bottom: 10px;
    }
    @media only screen and (max-width: 381px){
      .tab-content .container {
          width: 98%;
      }
    }
  </style>
</head>
<body>
  %include('component/navigation.tpl')

  <div class="container"><div class="section"><div class="row"><div class="col s12 m8 offset-m2">
    <ul class="tabs tabs-fixed-width">
      <li class="tab col s3"><a class="active" href="#tab-swipe-ap">AP Mode</a></li>
      <li class="tab col s3"><a href="#tab-swipe-sta">Station Mode</a></li>
    </ul>

    <div id="tab-swipe-ap" class="col s12 orange lighten-5 tab-content"><div class="container">
        <div class="col s12">
            <h5 class="center black-text center">Set Wireless to AP Mode</h5>
        </div>
        <div class="input-field col s12">
          <i class="material-icons prefix">wifi_tethering</i>
          <input id="inputApName" type="text" class="validate" required autofocus>
          <label for="inputApName">Access Point Name</label>
        </div>
        <div class="input-field col s12">
          <i class="material-icons prefix">lock</i>
          <input id="inputApPasswd" type="password" class="validate" required autofocus>
          <label for="inputApPasswd">Password</label>
        </div>
        <div class="col s12 center">
          <button class="waves-effect waves-light btn-large" disabled name="ap">Submit</button>
        </div>
        <div class="col s12">
          <h7 class="center pink-text text-darken-2 result_msg"</h7>
        </div>
    </div></div>

    <div id="tab-swipe-sta" class="col s12 teal lighten-5 tab-content"><div class="container">
        <div class="col s12">
            <h5 class="center black-text center">Set Wireless to Station Mode</h5>
        </div>
        <div class="input-field col s12">
          <select id="ap_list">
            <option value="" disabled selected>Select an AP</option>
            %from utils import wireless
            %ap_array = wireless.scan_wifi()
            %for ap in ap_array:
            %essid = ap["essid"]
            %quality = ap["quality"]
            %encry = ap["encryption"]
            <option value="{{essid}}">{{essid}}&nbsp;&nbsp;({{encry}},&nbsp;{{quality}}%)
            </option>
            %end
          </select>
          <label class="red-text">Available AP list</label>
        </div>
        <br><br>
        <div class="row">
          <div class="input-field col s8">
            <i class="material-icons prefix">lock</i>
            <input id="inputStaPasswd" type="password" class="validate" required autofocus disabled>
            <label for="inputStaPasswd">Password</label>
          </div>
          <div class="col s4 input-field right">
            <p><label>
              <input id="inputStaSave" type="checkbox" class="filled-in" disabled checked="checked" />
              <span>Save</span>
            </label></p>
          </div>

          <div class="col s12 input-field"><p><label>
            <input id="inputStaAdvance" type="checkbox" disabled class="filled-in"/>
            <span>Show Advanced options</span>
          </label></p></div>
          <div id="StaAdvancedOptionBlock"></div>

          <div class="col s12 center">
            <button class="waves-effect waves-light btn-large" disabled name="sta">Submit</button>
          </div>
          <div class="col s12">
            <h6 class="center pink-text text-darken-2 result_msg"</h6>
          </div>
        </div>
    </div></div>
  </div></div></div></div>


  %include('component/footer.tpl')
  <script src="/js/xmlhttp.min.js"></script>
  <script>
    function check_ap_input()
    {
      var ssid = $("#inputApName").val();
      var password = $("#inputApPasswd").val();
      if (ssid.length != 0 && password.length >= 8) {
          $("#tab-swipe-ap button").attr("disabled", false);
      }else{
        $("#tab-swipe-ap button").attr("disabled", true);
      }
    }
    function check_sta_input()
    {
      var adv_option = false;
      var fill_in_status = false;
      if( $("#static_ipaddr").length > 0 ){
        adv_option = true;
      }
      if(adv_option){
        var exp_ip = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/; 
        var exp_mask =/^(254|252|248|240|224|192|128|0)\.0\.0\.0|255\.(254|252|248|240|224|192|128|0)\.0\.0|255\.255\.(254|252|248|240|224|192|128|0)\.0|255\.255\.255\.(254|252|248|240|224|192|128|0)$/; 
        if( $("#inputStaPasswd").val().length>=8 
            && null!=$("#static_ipaddr").val().match(exp_ip)
            && null != $("#static_gateway").val().match(exp_ip)
            && null != $("#static_mask").val().match(exp_mask)
        ){
          fill_in_status = true;
        }
      }else{
        fill_in_status = ($("#inputStaPasswd").val().length >= 8);
      }
      if (fill_in_status) {
        
          $("#tab-swipe-sta button").attr("disabled", false);
      }else{
        $("#tab-swipe-sta button").attr("disabled", true);
      }
    }

    function show_status_msg(msg, ms)
    {
      $(".result_msg").html(msg);
      setTimeout( function(){$(".result_msg").html("");}, ms/*1500*/);
    }

  $(document).ready(function(){
    $('.tabs').tabs();
    var elem = document.querySelector('#ap_list');
    var instance = M.Select.init(elem, '');

    $("#inputApName").keyup(check_ap_input);
    $("#inputApPasswd").keyup(check_ap_input);
    $("#inputStaPasswd").keyup(check_sta_input);


    $("#ap_list").change(function(){
      $("#inputStaPasswd").attr("disabled", true);
      $("#inputStaSave").attr("disabled", true);
      $("#tab-swipe-sta button").attr("disabled", true);
      $("#inputStaPasswd").val(null);

      $("#inputStaAdvance").attr("checked",false);
      $("#StaAdvancedOptionBlock").empty();

      XMLHttp.sendRequest( "/network/settings", "post", "get_saved_ap", "",function(xmlhttp){
        var json= eval( "(" + xmlhttp.responseText + ")" );
        var ssid = $("#ap_list").val();
        var key = eval("json['" + $("#ap_list").val() + "']");
        if(typeof key == "undefined"){
          $("#inputStaPasswd").attr("disabled", false);
          $("#inputStaSave").attr("disabled", false);
          $("#inputStaAdvance").attr("disabled", false);
          return;
        } else {
          $("#inputStaPasswd").val(key);
          $("#inputStaAdvance").attr("disabled", true);
          $("#tab-swipe-sta button").attr("disabled", false);
        }
      });
    });

    $("#inputStaAdvance").change(function(){
      var adv = ($(this).is(":checked"))? true: false;
      if(adv){
        var block = $("#StaAdvancedOptionBlock");
        block.addClass("col s12");
        var content = 
          '<div class="row">' +
            '<div class="col s12 m6"><select id="sta_dhcp">' + 
                '<option value="dhcp" selected>DHCP</option>' +
                '<option value="static">static</option>' +
            '</select></div>' + '<div id="sta_static"></div>' + 
          '</div>';
        block.html(content);
        $('#sta_dhcp').select();

        $("#sta_dhcp").change(function(){
          if( "static" == $(this).val()){
            content =
              '<div class="col s12"><div class="row">' +
              '<div class="input-field col s12 m4">' +
                '<input id="static_ipaddr" type="text" class="validate" placeholder="192.168.1.128">' +
                '<label class="active" for="static_ipaddr">IP Address</label>' +
              '</div>' +

              '<div class="input-field col s12 m4">' +
                '<input id="static_gateway" type="text" class="validate" placeholder="192.168.1.1">' +
                '<label class="active" for="static_gateway">Gateway</label>' +
              '</div>' +

              '<div class="input-field col s12 m4">' +
                '<input id="static_mask" type="text" class="validate" placeholder="255.255.255.0">' +
                '<label class="active" for="static_mask">Net Mask</label>' +
              '</div>' +
              '</div></div>';
            $("#sta_static").html(content);
            check_sta_input();
            $("#static_ipaddr").keyup(check_sta_input);
            $("#static_gateway").keyup(check_sta_input);
            $("#static_mask").keyup(check_sta_input);
          }else{
            $("#sta_static").empty();
          }

        });
      }
      else{
        $("#StaAdvancedOptionBlock").empty();
      }
    });

    $("button").click(function(){
      var mode = $(this).attr("name");
      var ssid = null;
      var password = null;
      var save = null;
      if(mode=="ap"){
        ssid = $("#inputApName").val();
        password = $("#inputApPasswd").val();

        // if (ssid.length == 0) {
        //   alert("AP neme setting error!");
        //   return;
        // }
        // if( password.length < 8 ){
        //     alert("Invalid Password, the minimal length is 8!");
        //     return;
        // }
      }else if(mode=="sta"){
        ssid = $("#ap_list").val();
        if(ssid==null){
          return;
        }
        password = $("#inputStaPasswd").val();
        if( $("#inputStaSave").prop("disabled")==false ){
          // if($("#inputStaPasswd").val()==""){
          //   alert("please input passowrd !!!");
          //   return;
          // }
          save = ($("#inputStaSave").is(":checked"))? ("true") : ("false");
        }else{
          save = "noneed";
        }
      }else return;

      var data = "mode=" + mode + "&ssid=" + ssid + "&password=" + password;
      if(mode=="sta"){
        var adv_option = "no";
        if( $("#static_ipaddr").length > 0 ){
          adv_option = "yes" + "&ipaddr=" + $("#static_ipaddr").val()
            + "&gateway=" + $("#static_gateway").val() + "&netmask=" + $("#static_mask").val();
        }
        data += "&save=" + save + "&adv_option=" + adv_option;
      }
      XMLHttp.sendRequest( "/network/settings", "post", "set_wireless", data, function(xmlhttp){
        var stat = xmlhttp.responseText;
        show_status_msg("set wireless " + stat);
      });
    });

  });
  </script>
</body>
</html>
