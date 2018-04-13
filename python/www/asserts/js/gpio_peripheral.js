var operation = {
	action: "error",
	device: "error",
	channel: "error",
	pinmux: "error",
	slave: "error"
};
var chip_i2c = {
	chanls: "error",
	pinmuxs: "error",
	pins: "error"
};
var chip_spi = {
	chanls: "error",
	pinmuxs: "error",
	pins: "error",
	is_slave: "error"
};
var chip_uart = {
	chanls: "error",
	pinmuxs: "error",
	pins: "error"
};
var device_status = {
	i2c: "error",
	spi: "error",
	uart: "error"
};

function disable_select(elem)
{
	if( $(elem).attr("disabled") != "disabled" ){
		$(elem).attr("disabled", true);
		var instance = M.Select.init(elem, '');
		instance.destroy();
	}
}


function enable_select(elem)
{
	if( $(elem).attr("disabled") == "disabled" ){
		$(elem).attr("disabled", false);
		var instance = M.Select.init(elem, '');
	}
}

function update_attached_dev_info(cmd, dev, chnls){
	XMLHttp.sendRequest( "/gpio/peripheral", "post", "get_per_dev_status", ("dev=" + dev),
		function(xmlhttp){
			var json = eval( "(" + xmlhttp.responseText + ")" );
			var elem = document.querySelector('#device_channel');
			disable_select(elem);
			for (var i=0; i<chnls; i++) {
					var pinmux = eval("json.chn" + i); //0xff means uninstalled in this channel
					if( cmd == "add" && 0xff != pinmux )
						$("#device_channel option[value=" + i + "]").attr("disabled", true);
					else if( cmd == "remove" && 0xff == pinmux )
						$("#device_channel option[value=" + i + "]").attr("disabled", true);
			}
			enable_select(elem);
	});
}

function create_device_subdivs()
{
	var dev_option = $("#device_type");
	var devname = operation.device;
	var chip_dev = eval( "chip_" + devname );
	if(chip_dev.chanls=="error" && chip_dev.pinmuxs=="error" && chip_dev.pins=="error"){
		var chanls = parseInt( dev_option.find('option:selected').attr("data-chnls") );
		chip_dev.chanls = chanls;
		chip_dev.pinmuxs = new Array(chanls);
		chip_dev.pins = new Array();
		eval("device_status." + devname + "= new Array(" + chanls + ")");
		var pins = dev_option.find('option:selected').attr("data-pins").split(";");
		for(var i=0; i<chanls; i++){
			eval("device_status." + devname + "[" + i + "] = 0xff" );
			chip_dev.pinmuxs[i] 
				= parseInt( dev_option.find('option:selected').attr("data-pinmux").split(";")[i] ); //pinmux count of channel n
			chip_dev.pins[i] = new Array(chip_dev.pinmuxs[i]);
			for(j=0; j<chip_dev.pinmuxs[i]; j++){
				chip_dev.pins[i] = pins[i];
			}
		}
	}

	var elem = document.querySelector('#device_channel');
	disable_select(elem);
	$("#device_channel").empty();
	disable_select(document.querySelector('#device_pinmux'));
	$("#device_pinmux").empty();
	disable_select(document.querySelector('#spi_slave'));

	$("#operate_confirm").css("display", "none");

	$("#device_channel").append('<option value="null" selected disabled>Channel</option>');
	for(var i=0;i<chip_dev.pins.length;i++){ // for each channel
		var pins = chip_dev.pins[i].split("**") + "";
		var match = pins.match( new RegExp(",", 'g') );
		var pinmux = match?match.length:0;
		$("#device_channel").append('<option value="' + i +'" ' + 'data-pinmux="' + pinmux
			+ '" data-pins="' + pins + '" data-dev="' + devname + '" data-chnls="' + i 
			+ '" data-cmd="' + operation.action +'">channel' + i +'</option>');
	}
	update_attached_dev_info(operation.action, operation.device, chip_dev.pins.length);

	enable_select(elem);

	return 0;
}


function create_channel_subdivs(channel)
{
	var channel_option = $("#device_channel");
	var channel = channel_option.val();
	var pins = channel_option.find('option:selected').attr("data-pins").split(",");
	var elem = document.querySelector('#device_pinmux');
	disable_select(elem);

	$("#device_pinmux").empty();
	disable_select(document.querySelector('#spi_slave'));
	$("#operate_confirm").css("display", "none");

	$("#device_pinmux").append('<option value="null" selected disabled>Pinmux</option>');
	for(var i=0;i<pins.length-1;i++){ // for each channel
		var pin = pins[i] + "";
		pin = pin.replace(new RegExp("#", 'g'), ",")
		$("#device_pinmux").append('<option value="' + i + '" data-pins="' + pin 
			+ '" data-dev="' + operation.device + '" data-chnl="' + channel + '" data-cmd="'
			+ operation.action + '">pinmux' + i /*+ '(' + pin + ')'*/ +'</option>');
	}
	enable_select(elem);

	return 0;
}

function send_operation_to_server()
{
	var msg = "Are you sure to " + operation.action + " " 
			+ operation.device +" (chnannel" + operation.channel;
	if(operation.action=="add"){
		msg += ", pinmux" + operation.pinmux;
		if(operation.device=="spi")
			msg += ", " + ( operation.slave=="1"? "slave mode" : "master mode");
	}
	msg += ")?\n";
	if( !confirm(msg) ) return;
	msg = "Please confirm again, wrong operation could well be cause system crash!";
	if( !confirm(msg) ) return;

	var cmd = operation.action;
	var dev = operation.device;
	var chnl = operation.channel;
	var mux = operation.pinmux;
	var is_slave = operation.slave;

	var data = "cmd=" + cmd + "&dev=" + dev + "&chnl=" + chnl;
	if(cmd=="add") data = data + "&pinmux=" + mux;
	if(dev=="spi") data = data + "&slave=" + is_slave;

	XMLHttp.sendRequest( "/gpio/peripheral", "post", "device_operate", data, function(xmlhttp){
		var ret = parseInt(xmlhttp.responseText)? false:true;
		msg = ((cmd == "add")? "Add":"Remove") + " device " + dev + " ( channel " + chnl;
		if(cmd == "add"){
			msg += ", pinmux " + mux;
			if(dev == "spi") msg += ", " + (is_slave=="1"? "slave":"master") + " mode";
		}
		msg += " )";
		if(ret) msg += " successfully!";
		else msg += "failed!";
		$("#result_msg").html(msg);
		setTimeout( function(){
			$("#result_msg").html("");
		}, 1500);

		if(ret){
			operation.action = "none";
			disable_select(document.querySelector("#device_operate"));
			disable_select(document.querySelector('#device_type'));
			disable_select(document.querySelector('#device_channel'));
			$("#device_channel").empty();
			disable_select(document.querySelector('#device_pinmux'));
			$("#device_pinmux").empty();
			disable_select(document.querySelector('#spi_slave'));
			$("#operate_confirm").css("display", "none");

			var pins;
			if(cmd=="add"){
				pins = eval("chip_" + dev + ".pins" + "[" + chnl + "]").split("**")[mux].split("#");
				for (var i = 0; i < pins.length; i++) {
					var name_num = pins[i].split("-");
					$("#pin" + parseInt(name_num[1]) + " .block.pin").addClass("function");
					$("#pin" + parseInt(name_num[1]) + " .block.pin").text(name_num[0]+chnl);
				}

				eval("device_status." + dev + "[" + chnl + "] = " + mux ); //update status
			}else{
				
				mux = eval("device_status."+dev+"["+chnl+"]")
				pins = eval("chip_" + dev + ".pins" + "[" + chnl + "]").split("**")[mux].split("#");
				for (var i = 0; i < pins.length; i++) {
					var name_num = pins[i].split("-");
					$("#pin" + parseInt(name_num[1]) + " .block.pin").removeClass("function");
					$("#pin" + parseInt(name_num[1]) + " .block.pin").text("");
				}

				eval("device_status." + dev + "[" + chnl + "] = 0xff" );
			}


		}
	});
}
function update_all_pin_status()
{
	//gpio status update need be accomplished here

	//device status


	var dev = ["i2c", "spi", "uart"];
	for (var i = 0; i < dev.length; i++) {
		if(dev[i].chanls=="error" && dev[i].pinmuxs=="error" && dev[i].pins=="error") continue;
		if(typeof eval("device_status."+dev[i]) == "string") continue;
		var chnls = eval("device_status." + dev[i]).length;
		for (var j=0; j < chnls; j++) {
			var mux = eval("device_status." + dev[i] + "[" + j + "]");
			var all_pins = eval("chip_" + dev[i] + ".pins" + "[" + j + "]").split("**")[mux];
			var name_num = all_pins.split("#").split("-");
			if(mux!=0xff){
				$("#pin" + parseInt(name_num[1]) + " .block.pin").addClass("function");
				$("#pin" + parseInt(name_num[1]) + " .block.pin").text("");
			}
		}
	}

}

$(document).ready(function(){
	var confirm_btn = $("#operate_confirm");
	confirm_btn.css("display", "none");
	update_all_pin_status();

	$("#device_operate").change(function(){
		var action = $(this).val();
		if(action != operation.action){
			disable_select(document.querySelector('#device_channel'));
			$("#device_channel").empty();
			disable_select(document.querySelector('#device_pinmux'));
			$("#device_pinmux").empty();
			disable_select(document.querySelector('#spi_slave'));
			confirm_btn.css("display", "none");

			operation.action = action;
			operation.device = "none";
			operation.channel = "none";
			operation.pinmux = "none";
			operation.slave = "none";

			var elem = document.querySelector('#device_type');
			disable_select(elem);
			$("#device_type").val("null");
			enable_select(elem);
		}
		$("#device_chnl_div").empty();
	});

	$("#device_type").change(function(){
		var device = $(this).val();
		if(device != operation.device){
			operation.device = device;
			operation.channel = "none";
			operation.pinmux = "none";
			operation.slave = "none";
			if( device=="i2c" || device=="spi" || device=="uart"){
				var ret = create_device_subdivs();
			}
		}
	});

	$("#device_channel").change(function(){
		var channel = $(this).val();
		if(channel != operation.channel){
			operation.channel = channel;
			operation.pinmux = "none";
			operation.slave = "none";
			if(operation.action == "remove") {
				$("#operate_confirm button").text( "confirm " + operation.action);
				if( confirm_btn.css("display") == "none" ){
					confirm_btn.css("display", "block");
				}
			}else{
				return create_channel_subdivs();
			}
		}
	});

	$("#device_pinmux").change(function(){
		var pinmux = $(this).val();
		if(pinmux != operation.pinmux){
				operation.pinmux = pinmux;
				operation.slave = "none";

			if(operation.device == "spi"){
				var elem = document.querySelector('#spi_slave');
				enable_select(elem);
				return;
			}
			$("#operate_confirm button").text( "confirm " + operation.action);
			if ( confirm_btn.css("display") == "none" ){
					confirm_btn.css("display", "block");
			}
		}
	});

	$("#spi_slave").change(function(){
		var is_slave = $(this).val();
		if(is_slave != operation.slave){
				operation.slave = is_slave;
			$("#operate_confirm button").text( "confirm " + operation.action);
			if( confirm_btn.css("display") == "none" ){
					confirm_btn.css("display", "block");
			}
		}
	});

	$("#operate_confirm button").click(send_operation_to_server);

	$("#active_operate").click(function(){
		var elem = document.querySelector('#device_operate');
			enable_select(elem);
	});

});
