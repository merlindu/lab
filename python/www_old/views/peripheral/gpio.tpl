<!DOCTYPE html>
<html>
<head>
	<title>peripheral</title>
	%include('head.tpl')
	<style type="text/css">
		table{
			border: 0px solid #ffffff;
			cellpadding: 0px;
			cellspacing: 0px;
			width: 55%; 
			height: 50%; 
			float: left;
		}
		.section-pins{
			margin: 0px;
			margin-bottom: 20px;
		}
		.section-chip-control{
			margin-top: 20px;
		}
		.dev-control-select>select{
			width: 80%;
			height: 50px;
			float: center;
			font: 25px/20px "Microsoft YaHei";
			margin: 0px;
		}
		 .dev-control-select-spi{
		 	max-width: 110px;
		 	padding-left: 0px;
		 	padding-right: 0px;
		 	margin-right: 0px;
		 }
		 .dev-control-select-spi>select{
		 	width: 100%;
		 }
		 #operate_confirm_div{
		 	padding-left: 15px;
		 }
		 #operate_confirm_div button{
		 	margin-top: 2px;
		 }
		.section-hide{
			display: none;
		}
		.pin-block-wrap {
			margin: 0;
			padding: 0;
			
			width: 350px;
			height: 50px;
		}
		.pin-block {
			position: relative;
			z-index: 1;
			overflow: hidden;
			width: 50px;
			height: 50px;
			text-align: center;
			float: left;
			border: 1px solid #ffffff;
		}
		.pin-block img {
			width: 100%;
			height: 100%;
			display: block;
		}
		.pin-block-context {
			position: absolute;
			top: 20%;
			width: 48px;
			height: 48px;
			z-index: 2;
			font-size: 20px;
		}
		.pin-label-display{
			color: #0070ff;
			display: block;
		}
		.pin-label-hidden{
			color: #aeaeae;
			display: none;
		}
		.dev-label {
			top: 35%;
			font-size: 10px;
		}
		body{
			padding-left: 11px;
		}
		#operation_result{
			text-align: center;
			color: #b90000;
			margin-top: 10px;
			font-size: 30px;
			font-family: "Times New Roman", Georgia, Serif;
		}
		.block-termimal{
			width: 100%;
			height: 100%;
		}
		#shellinabox{
			height: 400px;
			padding: 0px;
			margin: 0px;
			background-color: #d9ecff;
			text-align: center;
			line-height: 400px;
			font-size: 30px;
			cursor: pointer; 
		}
	</style>
	<script type="text/javascript">
		fm_i2c_status = new Array();
		fm_i2c_pins = new Array();
		fm_i2c_pins_inited = 0;

		fm_spi_pins = new Array();
		fm_spi_status = new Array();
		fm_spi_pins_inited = 0;

		fm_uart_pins = new Array();
		fm_uart_status = new Array();
		fm_uart_pins_inited = 0;
		function set_pin_to_gpio(pin, str){
			var blk = $("#pin" + pin);
			var img = blk.find("img");
			var label = blk.find("div"); 

			img.attr('src',"/images/pin_gpio.png");
			img.attr('data-src',"/images/pin_gpio.png");
			if ( label.hasClass("pin-label-hidden") ){
				label.removeClass("pin-label-hidden");
			}
			label.attr('data-display',"block");
		}
		function set_pin_to_func(pin){
			var blk = $("#pin" + pin);
			var img = blk.find("img");
			var label = blk.find("div"); 

			img.attr('src',"/images/pin_fun.png");
			img.attr('data-src',"/images/pin_fun.png");
			if ( label.hasClass("pin-label-hidden") ){
				label.removeClass("pin-label-hidden");
			}
			label.attr('data-display',"block");
		}
		function set_pin_to_dev(pin, name){
			var blk = $("#pin" + pin);
			var img = blk.find("img");
			var label = blk.find("div"); 

			img.attr('src',"/images/pin_dev.png");
			img.attr('data-src',"/images/pin_dev.png");
			label.html(name);
			label.addClass("dev-label");
			if ( label.hasClass("pin-label-hidden") ){
				label.removeClass("pin-label-hidden");
			}
			label.attr('data-display',"block");
		}
		function restore_pin_from_dev(pin){
			var blk = $("#pin" + pin);
			var img = blk.find("img");
			var label = blk.find("div");

			if ( label.hasClass("pin-label-hidden") ){
				label.removeClass("pin-label-hidden");
				label.attr('data-display',"block");
			}
			if (blk.attr("data-func") == "func") {
				img.attr('src',"/images/pin_fun.png");
				img.attr('data-src',"/images/pin_fun.png");
			} else if (blk.attr("data-func") == "gpio") {
				img.attr('src',"/images/pin_gpio.png");
				img.attr('data-src',"/images/pin_gpio.png");
			} else if (blk.attr("data-func") == "unknown") {
				img.attr('src',"/images/pin_block.png");
				img.attr('data-src',"/images/pin_block.png");

				if ( !label.hasClass("pin-label-hidden") ){
					label.addClass("pin-label-hidden");
					label.attr('data-display',"none");
				}
			}
			if ( label.hasClass("dev-label") )
				label.removeClass("dev-label");
			label.html(label.attr("title"));
		}

		function device_change(){
			var Qobj = $("#device_pinmux");
			if(Qobj.length == 0)
				Qobj = $("#device_channel");

			var cmd = Qobj.find('option:selected').attr("data-cmd");
			var dev = Qobj.find('option:selected').attr("data-dev");
			var chn = Qobj.find('option:selected').attr("data-chnl");

			var pinmux = -1;
			if(cmd=="add") pinmux = Qobj.val();
			else pinmux = eval("fm_" + dev + "_status[" + chn + "]");

			if( (cmd=="add" && (typeof Qobj.val() == "undefined")) || (typeof chn == "undefined") ){
				alert("Please set correct argument!");
				return;
			}

			var hint = "Are you sure to " + cmd + " " + dev +" (chnannel" + chn;
			if(cmd=="add"){
				hint = hint + ", pinmux" + pinmux;
				if(dev == "spi")
					hint = hint + ", " + ( $("#spi_slave").val()=="1"? "slave mode" : "master mode");
			}
			hint = hint + ")?\n";
			if( !confirm(hint) ) return;
			hint = "Please confirm again, wrong operation could well be cause system crash!";
			if( !confirm(hint) ) return;

			var data = "cmd=" + cmd + "&dev=" + dev + "&chnl=" + chn;
			if(cmd=="add") data = data + "&pinmux=" + pinmux;
			if(dev=="spi") data = data + "&slave=" + $("#spi_slave").val();

			XMLHttp.sendRequest( "post", "gpio_operate", data, function(xmlhttp){
				var ret = parseInt(xmlhttp.responseText);
				if ( $("#operation_result").hasClass("section-hide") ){
					$("#operation_result").removeClass("section-hide");
				}
				var msg = ((cmd == "add")? "Add":"Remove") + " device " + dev + " ( channel " + chn;
				if(cmd == "add"){
					msg = msg + ", pinmux " + pinmux;
					if(dev == "spi") msg = msg + ", " + ( ( parseInt($("#spi_slave").val()) )? "slave":"master" ) + " mode";
				}
				if(ret) $("#operation_result").html(msg + " ) failed!");
				else $("#operation_result").html(msg + " ) successfully.");

				setTimeout( function(){
					$("#operation_result").addClass("section-hide");
				}, 1500);
			});

			update_dev_attach_info();

			var pin_num = 0;
			if(dev == "i2c") {
				for(i=0;i<fm_i2c_pins.length;i++){
					update_chnl_option(cmd, "i2c", i);
				}
				pin_num = 2;
			}
			else if(dev == "spi") {
				for(i=0;i<fm_spi_pins.length;i++){
					update_chnl_option(cmd, "spi", i);
				}
				pin_num = 5;
			}
			else if(dev == "uart") {
				for(i=0;i<fm_uart_pins.length;i++){
					update_chnl_option(cmd, "uart", i);
				}
				pin_num = 4;
			}

			/*=====update pin block display>>>>>*/
			if (cmd == "add") {
				var pins = Qobj.find('option:selected').attr("data-pins").split(",");
				for(var i=0; i<pin_num; i++){
					var info = pins[i].split("-");
					set_pin_to_dev(parseInt(info[1]), info[0] + "-" + chn);
				}
			} else {
				var pins = Qobj.find('option:selected').attr("data-pins").split(";")[pinmux].split(",");
				for(var i=0; i<pin_num; i++){
					restore_pin_from_dev( parseInt(pins[i].split("-")[1]) );
				}
			}
			/*=====update pin block display<<<<<*/
			$("#device_pinmux_div").empty();
			$("#spi_slave_div").empty();
			if ( !$("#operate_confirm_div").hasClass("section-hide") ){
				$("#operate_confirm_div").addClass("section-hide");
			}
			$("#device_channel option[value='null']").prop("selected", "selected");
			$("#device_type option[value='null']").prop("selected", "selected");
			$("#devive_operate option[value='null']").prop("selected", "selected");
		}

		function update_chnl_option(cmd, dev, chn){
			var pinmux = eval("fm_" + dev + "_status[" + chn + "]");
			if( cmd == "add" && 0xff != pinmux )
				$("#device_channel option[value=" + chn + "]").attr("disabled", true);
			else if( cmd == "remove" && 0xff == pinmux )
				$("#device_channel option[value=" + chn + "]").attr("disabled", true);
		}

		function update_dev_attach_info(){
			var chnl = parseInt( $("#device_type").find("option[value='i2c']").attr("data-chnl") );
			XMLHttp.sendRequest( "post", "get_per_dev_status", "dev=i2c", function(xmlhttp){
				var jsonstring = xmlhttp.responseText;
				var json = eval( "("+jsonstring+")" );
				for (var i=0; i<chnl; i++) {
					var pinmux = eval("json.chn" + i);
					fm_i2c_status[i] = pinmux;
				}
			});
			chnl = parseInt( $("#device_type").find("option[value='spi']").attr("data-chnl") );
			XMLHttp.sendRequest( "post", "get_per_dev_status", "dev=spi", function(xmlhttp){
				var jsonstring = xmlhttp.responseText;
				var json = eval( "("+jsonstring+")" );
				for (var i=0; i<chnl; i++) {
					var pinmux = eval("json.chn" + i);
					fm_spi_status[i] = pinmux;
				}
			});
			chnl = parseInt( $("#device_type").find("option[value='uart']").attr("data-chnl") );
			XMLHttp.sendRequest( "post", "get_per_dev_status", "dev=uart", function(xmlhttp){
				var jsonstring = xmlhttp.responseText;
				var json = eval( "("+jsonstring+")" );
				for (var i=0; i<chnl; i++) {
					var pinmux = eval("json.chn" + i);
					fm_uart_status[i] = pinmux;
				}
			});
		}

		$(document).ready(function(){
			var length = parseInt( $(".section-pins").attr("data-count") );
			XMLHttp.sendRequest( "post", "get_pin_status", "null", function(xmlhttp){
				var jsonstring = xmlhttp.responseText;
				var jsons = eval( "("+jsonstring+")" );
				for (var i=0; i<length; i++) {
					var json = eval("jsons.pin" + i);

					var name = json.name;
					var func = json.func;

					var blk = $("#pin" + i);
					var img = blk.find("img");
					var label = blk.find("div");

					if (func==0) { //gpio
						set_pin_to_gpio(i, "dir: " + json.dir + ", level: " + json.level);
						blk.attr("data-func", "gpio");
					} else {
						blk.attr("data-func", "func");
						set_pin_to_func(i);
						if (name.match("FMGPIO") == null) { /*means this pin binds to a device*/
							set_pin_to_dev(i, name);
						}
					}
				}
			});

			update_dev_attach_info();

			$(".pin-block .context").bind({
				click:function () {
					$(this).prev().trigger("click");
				}
			});
			$(".pin-block img").bind({
				click:function () {
					$(this).parent().trigger("click");
				}
			})

			$(".pin-block").bind({
				click:function () {
					var img = $(this).find("img");
					img.attr('src',"/images/pin_selected.png");
					if( img.next().hasClass("pin-label-hidden") )
						img.next().removeClass("pin-label-hidden");
					img.next().addClass("pin-label-display");
				},
				mouseleave:function () {
					var img = $(this).find("img");
					if( img.attr('src') == "/images/pin_selected.png" )
						img.attr('src', img.attr("data-src")); 

					if( img.next().hasClass("pin-label-display") )
						img.next().removeClass("pin-label-display");

					if( img.next().attr('data-display') == "none" )
						img.next().addClass("pin-label-hidden");
				}
			});

			$("#operate_confirm_div button").bind({
				click:function () {
					device_change();
				},
			});

			$("#devive_operate").bind({
				change:function () {
					$("#device_type").val("null");
					$("#device_chnl_div").empty();
					$("#device_pinmux_div").empty();
					$("#device_type").removeClass("section-hide");
				},
				click:function () {
				}
			});

			$("#device_type").bind({
				change:function () {
					var cmd_operate = $("#devive_operate").val();
					id = this;
					$("#device_chnl_div").empty();
					$("#device_pinmux_div").empty();
					if( !$("#operate_confirm_div").hasClass("section-hide") ){
						$("#operate_confirm_div").addClass("section-hide");
					}
					$("#spi_slave_div").empty();

					if( $(id).val() == null ) {
						return;
					} else if ( $(id).val()=="i2c" ){
						if( fm_i2c_pins_inited != 1 ){
							channels = parseInt( $(id).find('option:selected').attr("data-chnl") );
							var pinmux = new Array(channels);
							var pins_parse = $(id).find('option:selected').attr("data-pins").split(";");
							var pin_index = 0;
							for( i=0; i<channels; i++ ){
								pinmux[i] = parseInt( $(id).find('option:selected').attr("data-pinmux").split(";")[i] ); //pinmux of channel n
								fm_i2c_pins[i] = new Array(pinmux[i]);
								for(j=0; j<pinmux[i]; j++){
									fm_i2c_pins[i][j] = pins_parse[pin_index+j];
								}
								pin_index = pin_index + pinmux[i]
							}
							fm_i2c_pins_inited = 1;
						}
						//re-create device_chnl_div >>>>>
						$("#device_chnl_div").append('<select name="channel" id="device_channel"></select>');
						$("#device_channel").append('<option value="null" selected disabled>Channel</option>');
						for(i=0;i<fm_i2c_pins.length;i++){
							var pins_in_chnl ="";
							for(j=0;j<fm_i2c_pins[i].length;j++){
								pins_in_chnl = pins_in_chnl + fm_i2c_pins[i][j] + ";";
							}
							$("#device_channel").append('<option value="' + i +'" ' + 'data-pinmux_cnt="' + fm_i2c_pins[i].length
								+ '" data-pins="' + pins_in_chnl + '" data-dev="i2c" data-chnl="' + i + '" data-cmd="' + cmd_operate
								+'">channel' + i +'</option>');
							update_chnl_option(cmd_operate, "i2c", i);
						}
						$("#device_channel").bind({
							change:function () {
								var obj = this;
								if(cmd_operate=="remove"){
									if ( $("#operate_confirm_div").hasClass("section-hide") ){
										$("#operate_confirm_div").removeClass("section-hide");
									}
								} else {
									//re-create device_pinmux_div >>>>>>
									$("#device_pinmux_div").empty();
									$("#device_pinmux_div").append('<select name="pinmux" id="device_pinmux"></select>');
									$("#device_pinmux").append('<option value="null" selected disabled>Pinmux</option>');
									var muxs =  parseInt( $(obj).find('option:selected').attr("data-pinmux_cnt") );
									var pins_parse = $(obj).find('option:selected').attr("data-pins").split(";");
									var channel = $(obj).val();
									for(i=0; i<muxs; i++) {
										$("#device_pinmux").append('<option value="' + i + '" title="' + pins_parse[i] + '" data-pins="' + pins_parse[i]
											+ '" data-dev="i2c" data-chnl="' + channel + '" data-cmd="' + cmd_operate 
											+ '">pinmux' + i + '</option>');
									}
									//re-create device_pinmux_div <<<<<<
									$("#device_pinmux").bind({
										change:function () {
											if ( $("#operate_confirm_div").hasClass("section-hide") ){
												$("#operate_confirm_div").removeClass("section-hide");
											}
										}
									});
								}
							}
						});
						//re-create device_chnl_div <<<<<
						return;
					} else if ( $(id).val()=="spi" ){
						if( fm_spi_pins_inited != 1 ){
							channels =  parseInt( $(id).find('option:selected').attr("data-chnl") );
							var pinmux = new Array(channels);
							var pins_parse = $(id).find('option:selected').attr("data-pins").split(";");
							var pin_index = 0;
							for( i=0; i<channels; i++ ){
								pinmux[i] = parseInt( $(id).find('option:selected').attr("data-pinmux").split(";")[i] ); //pinmux of channel n
								fm_spi_pins[i] = new Array(pinmux[i]);
								for(j=0; j<pinmux[i]; j++){
									fm_spi_pins[i][j] = pins_parse[pin_index+j].replace(/,Master/,'');
								}
								pin_index = pin_index + pinmux[i]
							}
							fm_spi_pins_inited = 1;
						}
						//re-create device_chnl_div >>>>>
						$("#device_chnl_div").append('<select name="channel" id="device_channel"></select>');

						$("#device_channel").append('<option value="null" selected disabled>Channel</option>');
						for(i=0;i<fm_spi_pins.length;i++){
							var pins_in_chnl ="";
							for(j=0;j<fm_spi_pins[i].length;j++){
								pins_in_chnl = pins_in_chnl + fm_spi_pins[i][j] + ";";
							}
							$("#device_channel").append('<option value="' + i +'" ' + 'data-pinmux_cnt="' + fm_spi_pins[i].length
								+ '" data-pins="' + pins_in_chnl + '" data-dev="spi" data-chnl="' + i + '" data-cmd="' + cmd_operate
								+'">channel' + i +'</option>');
							update_chnl_option(cmd_operate, "spi", i);
						}
						$("#device_channel").bind({
							change:function () {
								var obj = this;
								if(cmd_operate=="remove"){
									if ( $("#operate_confirm_div").hasClass("section-hide") ){
										$("#operate_confirm_div").removeClass("section-hide");
									}
								} else {
									//re-create device_pinmux_div >>>>>>
									$("#device_pinmux_div").empty();
									$("#spi_slave_div").empty();
									$("#device_pinmux_div").append('<select name="pinmux" id="device_pinmux"></select>');
									$("#device_pinmux").append('<option value="null" selected disabled>Pinmux</option>');
									var muxs =  parseInt( $(obj).find('option:selected').attr("data-pinmux_cnt") );
									var pins_parse = $(obj).find('option:selected').attr("data-pins").split(";");
									var channel = $(obj).val();
									for(i=0; i<muxs; i++) {
										$("#device_pinmux").append('<option value="' + i + '" title="' + pins_parse[i] + '" data-pins="' + pins_parse[i]
											+ '" data-dev="spi" data-chnl="' + channel + '" data-cmd="' + cmd_operate
											+ '">pinmux' + i + '</option>');
									}
									//re-create device_pinmux_div <<<<<<
									$("#device_pinmux").bind({
										change:function () {
											if ( !$("#operate_confirm_div").hasClass("section-hide") ){
												$("#operate_confirm_div").addClass("section-hide");
											}

											$("#spi_slave_div").empty();
											$("#spi_slave_div").append('<select name="spi_mode" id="spi_slave"></select>');
											$("#spi_slave").append('<option value="null" selected disabled>mode</option>');
											$("#spi_slave").append('<option value="0">master</option>');
											$("#spi_slave").append('<option value="1">slave</option>');
											$("#spi_slave").bind({
												change:function (){
													if ( $("#operate_confirm_div").hasClass("section-hide") ){
														$("#operate_confirm_div").removeClass("section-hide");
													}
												}
											});

										}
									});
								}
							}
						});
						//re-create device_chnl_div <<<<<
						return;
					} else if ( $(id).val()=="uart" ){
						if( fm_uart_pins_inited != 1 ){
							channels =  parseInt( $(id).find('option:selected').attr("data-chnl") );
							var pinmux = new Array(channels);
							var pins_parse = $(id).find('option:selected').attr("data-pins").split(";");
							var pin_index = 0;
							for( i=0; i<channels; i++ ){
								pinmux[i] = parseInt( $(id).find('option:selected').attr("data-pinmux").split(";")[i] ); //pinmux of channel n
								fm_uart_pins[i] = new Array(pinmux[i]);
								for(j=0; j<pinmux[i]; j++){
									fm_uart_pins[i][j] = pins_parse[pin_index+j];
								}
								pin_index = pin_index + pinmux[i]
							}
							fm_uart_pins_inited = 1;
						}
						//re-create device_chnl_div >>>>>
						$("#device_chnl_div").append('<select name="channel" id="device_channel"></select>');

						$("#device_channel").append('<option value="null" selected disabled>Channel</option>');
						for(i=0;i<fm_uart_pins.length;i++){
							var pins_in_chnl ="";
							for(j=0;j<fm_uart_pins[i].length;j++){
								pins_in_chnl = pins_in_chnl + fm_uart_pins[i][j] + ";";
							}
							$("#device_channel").append('<option value="' + i +'" ' + 'data-pinmux_cnt="' + fm_uart_pins[i].length
								+ '" data-pins="' + pins_in_chnl + '" data-dev="uart" data-chnl="' + i + '" data-cmd="' + cmd_operate
								+'">channel' + i +'</option>');
							update_chnl_option(cmd_operate, "uart", i);
						}

						$("#device_channel").bind({
							change:function () {
								var obj = this;
								if(cmd_operate=="remove"){
									if ( $("#operate_confirm_div").hasClass("section-hide") ){
										$("#operate_confirm_div").removeClass("section-hide");
									}
								} else {
								//re-create device_pinmux_div >>>>>>
									$("#device_pinmux_div").empty();
									$("#device_pinmux_div").append('<select name="pinmux" id="device_pinmux"></select>');
									$("#device_pinmux").append('<option value="null" selected disabled>Pinmux</option>');
									var muxs =  parseInt( $(obj).find('option:selected').attr("data-pinmux_cnt") );
									var pins_parse = $(obj).find('option:selected').attr("data-pins").split(";");
									var channel = $(obj).val();
									for(i=0; i<muxs; i++) {
										$("#device_pinmux").append('<option value="' + i + '" title="' + pins_parse[i] + '" data-pins="' + pins_parse[i]
											+ '" data-dev="uart" data-chnl="' + channel + '" data-cmd="' + cmd_operate
											+ '">pinmux' + i + '</option>');
									}
									//re-create device_pinmux_div <<<<<<
									$("#device_pinmux").bind({
										change:function () {
											if ( $("#operate_confirm_div").hasClass("section-hide") ){
													$("#operate_confirm_div").removeClass("section-hide");
											}
										}
									});
								}
							}
						});
						//re-create device_chnl_div <<<<<
						return;
					} else return;
				},
				click:function () {
					if( $("#devive_operate").val() == null ){
						alert("please select add or remove firstly!");
					}
				}
			});
			$("#shellinabox").bind({
				click:function () {
					if( shellinbox != 1) {
						var data = "http://" + document.domain + ":" + "4200/";
						if( !confirm("Activate shellinabox web shell termimal?") ) return;
						$(this).empty();
						$(this).append('<object class="block-termimal" type="text/x-scriptlet" data="' + data + '" ></object>');
						shellinbox = 1;
					}
				}
			});
		});
		shellinbox = 0;
	</script>
</head>
<body>
	%include('navi.tpl')
	<div class='container'>
		<!-- all gpio pin show block>>>>>>>>>>>>>>>>>>>>>> -->
		%from fm_gpio import chip
		%length = chip.count
		<div class="section-pins" data-count="{{length}}">
			%#for aligned block=====>>>>>
			%cnt_cell = 7
			%cnt_row = cnt_cell *3
			%nr_row = length/cnt_row
			%nr_remain = length % cnt_row
			%id = 0
			%for i in range(nr_row):
			<div class="row">
				%for j in range(cnt_row/cnt_cell):
				<div class="col-sm-12 col-md-4 pin-block-wrap">
					%for k in range(cnt_cell):
					<div class="pin-block" id="pin{{chip.pin[id].num}}" data-func="unknown">
						<img src="/images/pin_block.png" data-src="/images/pin_block.png" title="{{chip.pin[id].num}}" alt="PIN">
						<div class="pin-block-context pin-label-hidden" data-display="none" title="{{chip.pin[id].num}}">{{id}}</div>
					</div>
					%id = id + 1
					%end
				</div>
				%end
			</div>
			%end

			%#for aligned block<<<<<=====

			%#for remaining block=====>>>>>
			<div class="row">
				%nr_cell = nr_remain / cnt_cell
				%nr_remain_last = nr_remain % cnt_cell
				%for j in range(nr_cell):
				<div class="col-sm-12 col-md-4 pin-block-wrap">
					%for k in range(cnt_cell):
					<div class="pin-block"  id="pin{{chip.pin[id].num}}" data-func="unknown">
						<img src="/images/pin_block.png" data-src="/images/pin_block.png" title="{{chip.pin[id].num}}" alt="PIN">
						<div class="pin-block-context pin-label-hidden" data-display="none" title="{{chip.pin[id].num}}">{{id}}</div>
					</div>
					%id = id + 1
					%end
				</div>
				%end
				<div class="col-sm-12 col-md-4 pin-block-wrap">
					%for k in range(nr_remain_last):
					<div class="pin-block"  id="pin{{chip.pin[id].num}}" data-func="unknown">
						<img src="/images/pin_block.png" data-src="/images/pin_block.png" title="{{chip.pin[id].num}}" alt="PIN">
						<div class="pin-block-context pin-label-hidden" data-display="none" title="{{chip.pin[id].num}}">{{id}}</div>
					</div>
					%id = id + 1
					%end

					%nr_null = cnt_cell - nr_remain_last
					%for k in range(nr_null):
					<div class="pin-placeholder"></div>
					%end
				</div>
			</div>
			%#for remaining block<<<<<=====
		</div>
		<!-- all gpio pin show block<<<<<<<<<<<<<<<<<<<<<< -->

		<!-- pin/device control panel>>>>>>>>>>>>>>>>>>>>>> -->
		<div class="row section-chip-control">
			<div class="col-sm-4 col-md-2 dev-control-select">
				<select name="operate" id="devive_operate">
					<option value="null" selected disabled>Operate</option>
					<option value="add">Add</option>
					<option value="remove">Remove</option>
				</select>
			</div>
			<div class="col-sm-4 col-md-2 dev-control-select">
				<select class="section-hide" name="device" id="device_type">
					<option value="null" selected disabled>Device</option>
					%length = len(chip.i2c)
					%if length > 0:
						%muxs = ""
						%pin_nums = ""
						%for i in range(length):
							%mux = len(chip.i2c[i])
							%muxs = muxs + str(mux) + ";"
								%for j in range(mux):
									%pin_nums = pin_nums + str(chip.i2c[i][j].sda.name) + "-" + str(chip.i2c[i][j].sda.num) + ","
									%pin_nums = pin_nums + str(chip.i2c[i][j].sck.name) + "-" + str(chip.i2c[i][j].sck.num) + ";"
								%end
						%end
					<option value="i2c" data-chnl="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">I2C</option>
					%end

					%length = len(chip.spi)
					%if length > 0:
						%muxs = ""
						%pin_nums = ""
						%for i in range(length):
							%mux = len(chip.spi[i])
							%muxs = muxs + str(mux) + ";"
								%for j in range(mux):
									%pin_nums = pin_nums + str(chip.spi[i][j].csn.name) + "-" + str(chip.spi[i][j].csn.num) + ","
									%pin_nums = pin_nums + str(chip.spi[i][j].din.name) + "-" + str(chip.spi[i][j].din.num) + ","
									%pin_nums = pin_nums + str(chip.spi[i][j].dout.name) + "-" + str(chip.spi[i][j].dout.num) + ","
									%pin_nums = pin_nums + str(chip.spi[i][j].clk.name) + "-" + str(chip.spi[i][j].clk.num) + ","
									%pin_nums = pin_nums + str(chip.spi[i][j].bsy.name) + "-" + str(chip.spi[i][j].bsy.num) + "," + chip.spi[i][j].mode + ";"
								%end
						%end
					<option value="spi" data-chnl="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">SPI</option>
					%end

					%length = len(chip.uart)
					%if length > 0:
						%muxs = ""
						%pin_nums = ""
						%for i in range(length):
							%mux = len(chip.uart[i])
							%muxs = muxs + str(mux) + ";"
								%for j in range(mux):
									%pin_nums = pin_nums + str(chip.uart[i][j].txd.name) + "-" + str(chip.uart[i][j].txd.num) + ","
									%pin_nums = pin_nums + str(chip.uart[i][j].rxd.name) + "-" + str(chip.uart[i][j].rxd.num) + ","
									%pin_nums = pin_nums + str(chip.uart[i][j].rts.name) + "-" + str(chip.uart[i][j].rts.num) + ","
									%pin_nums = pin_nums + str(chip.uart[i][j].cts.name) + "-" + str(chip.uart[i][j].cts.num) + ";"
								%end
						%end
					<option value="uart" data-chnl="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">UART</option>
					%end
				</select>
			</div>
			<div class="col-sm-4 col-md-2 dev-control-select" id="device_chnl_div"></div>
			<div class="col-sm-4 col-md-2 dev-control-select" id="device_pinmux_div"></div>
			<div class="col-sm-4 col-md-2 dev-control-select dev-control-select-spi" id="spi_slave_div"></div>
			<div class="col-sm-4 col-md-2 dev-control-select section-hide" id="operate_confirm_div">
				<button class="btn btn-lg btn-primary" type="submit">Send</button>
			</div>
		</div>
		<div class="row section-chip-control">
			<div class="col-sm-12 col-md-12 section-hide" id="operation_result"></div>
		</div>
		<!-- pin/device control panel<<<<<<<<<<<<<<<<<<<<<< -->
		<div class="row section-shellinabox">
			<div class="col-sm-12 col-md-12" id="shellinabox">Click to active web shell terminal</div>
		</div>
	</div>
	%include('footer.tpl')
</body>
</html>