<!DOCTYPE html>
<html lang="en">
<head>
  %include('component/head.tpl')
  <title>Peripheral</title>
  <link href="/css/gpio_peripheral.css" type="text/css" rel="stylesheet" media="screen,projection"/>
</head>
<body>
  %include('component/navigation.tpl')

  %from gpio_board import board as chip
  %length = chip.count


  <div class='container for_pins'>
    <div class="block-pins" data-count="{{length}}">
      %for id in range(length):
      <div class="colume">
        <div class="block pin-wrapper" id="pin{{chip.pin[id].num}}" data-func="unknown">
          <div class="block pin default"></div>
          <div class="block content blue-text center">{{chip.pin[id].num}}</div>
        </div>
      </div>
      %end
    </div>
  </div><!-- <div class='container for_pins'> -->

  <div class='container for_legend'><div class="row">
      <div class="col s4 m2">
        <div class="legend pin-wrapper">
          <div class="block legend pin default"></div>
          <div class="content blue-text center">unknown</div>
        </div>
      </div>
      <div class="col s4 m2">
        <div class="legend pin-wrapper">
          <div class="block legend pin disabled"></div>
          <div class="content blue-text center">unavailable</div>
        </div>
      </div>
      <div class="col s4 m2">
        <div class="legend pin-wrapper">
          <div class="block legend pin active"></div>
          <div class="content blue-text center">active</div>
        </div>
      </div>
      <div class="col s4 m2">
        <div class="legend pin-wrapper">
          <div class="block legend pin gpio"></div>
          <div class="content blue-text center">gpio</div>
        </div>
      </div>
      <div class="col s4 m2">
        <div class="legend pin-wrapper">
          <div class="block legend pin function"></div>
          <div class="content blue-text center">function</div>
        </div>
      </div>
  </div></div><!-- <div class='container for_legend'> -->





  <div class='container'><div class="row">
    <div class="col s12 m6">
      <button class="waves-effect waves-light btn" type="submit" name="action" id="active_operate">click to add or remove device
      </button>
    </div>
  </div></div>
  <div class='container for_device_operate'><div class="row">
    <div class="col s6 m3 l3 xl2">
      <div class="input-field col s12"><select disabled name="operate" id="device_operate">
        <option value="null" disabled selected>Operate</option>
        <option value="add">Add</option>
        <option value="remove">Remove</option>
      </select></div>
    </div>


    <div class="col s6 m3 l3 xl2">
      <div class="input-field col s12"><select disabled name="device" id="device_type">
        <option value="null" disabled selected>Device</option>
        %length = len(chip.i2c)
        %if chip.i2c == None or chip.i2c == [] or chip.i2c == [[]]:
          %length = 0
        %end
        %if length > 0:
          %muxs = ""
          %pin_nums = ""
          %for i in range(length):
            %mux = len(chip.i2c[i])
            %muxs = muxs + str(mux) + ";"
              %for j in range(mux):
                %pin_nums = pin_nums + str(chip.i2c[i][j].sda.name) + "-" + str(chip.i2c[i][j].sda.num) + "#"
                %pin_nums = pin_nums + str(chip.i2c[i][j].sck.name) + "-" + str(chip.i2c[i][j].sck.num) + "**"
              %end
              %pin_nums = pin_nums + ";"
          %end
        <option value="i2c" data-chnls="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">I2C</option>
        %end

        %length = len(chip.spi)
        %if chip.spi == None or chip.spi == [] or chip.spi == [[]]:
          %length = 0
        %end
        %if length > 0:
          %muxs = ""
          %pin_nums = ""
          %for i in range(length):
            %mux = len(chip.spi[i])
            %muxs = muxs + str(mux) + ";"
              %for j in range(mux):
                %pin_nums = pin_nums + str(chip.spi[i][j].csn.name) + "-" + str(chip.spi[i][j].csn.num) + "#"
                %pin_nums = pin_nums + str(chip.spi[i][j].din.name) + "-" + str(chip.spi[i][j].din.num) + "#"
                %pin_nums = pin_nums + str(chip.spi[i][j].dout.name) + "-" + str(chip.spi[i][j].dout.num) + "#"
                %pin_nums = pin_nums + str(chip.spi[i][j].clk.name) + "-" + str(chip.spi[i][j].clk.num) + "#"
                %pin_nums = pin_nums + str(chip.spi[i][j].bsy.name) + "-" + str(chip.spi[i][j].bsy.num) + "#" + chip.spi[i][j].mode + "**"
              %end
              %pin_nums = pin_nums + ";"
          %end
        <option value="spi" data-chnls="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">SPI</option>
        %end

        %length = len(chip.uart)
        %if chip.uart == None or chip.uart == [] or chip.uart == [[]]:
          %length = 0
        %end
        %if length > 0:
          %muxs = ""
          %pin_nums = ""
          %for i in range(length):
            %mux = len(chip.uart[i])
            %muxs = muxs + str(mux) + ";"
              %for j in range(mux):
                %pin_nums = pin_nums + str(chip.uart[i][j].txd.name) + "-" + str(chip.uart[i][j].txd.num) + "#"
                %pin_nums = pin_nums + str(chip.uart[i][j].rxd.name) + "-" + str(chip.uart[i][j].rxd.num) + "#"
                %pin_nums = pin_nums + str(chip.uart[i][j].rts.name) + "-" + str(chip.uart[i][j].rts.num) + "#"
                %pin_nums = pin_nums + str(chip.uart[i][j].cts.name) + "-" + str(chip.uart[i][j].cts.num) + "**"
              %end
              %pin_nums = pin_nums + ";"
          %end
        <option value="uart" data-chnls="{{length}}" data-pinmux="{{muxs}}" data-pins="{{pin_nums}}">UART</option>
        %end
      </select></div><!-- <div class="input-field col s12"> -->
    </div>
    <div class="col s6 m3 l3 xl2">
      <div class="input-field col s12"><select disabled name="channel" id="device_channel">
      </select></div>
    </div>
    <div class="col s6 m3 l3 xl2">
      <div class="input-field col s12"><select disabled name="channel" id="device_pinmux">
      </select></div>
    </div>
    <div class="col s6 m3 l3 xl2">
      <div class="input-field col s12"><select disabled name="spi_mode" id="spi_slave">
        <option value="null" selected disabled>mode</option>
        <option value="0">master</option>
        <option value="1">slave</option>
      </select></div>
    </div>
    <div class="col s6 m3 l3 xl2">
      <div id="operate_confirm">
        <button class="waves-effect waves-light btn" type="submit" name="action">
        </button>
      </div>
    </div>
    <div class="col s12">
      <h5 class="center pink-text text-darken-2" id="result_msg">
      </h5>
    </div>
  </div></div> <!-- <div class='container for_device_operate'> -->

  %include('component/footer.tpl')
  <script src="/js/xmlhttp.min.js"></script>
  <script src="/js/gpio_peripheral.min.js"></script>
</body>
</html>
