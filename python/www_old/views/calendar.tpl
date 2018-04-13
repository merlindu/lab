<div style="padding-bottom: 10px; text-align:center;" >
    <style type="text/css">
      .Calendar { font-family:Verdana; font-size:12px; background-color:#e0ecf9; margin-left:auto; margin-right:auto; text-align:center; width:800px; height:50px; padding:10px; line-height:1.5em; } 
      .Calendar a{ color:#1e5494; } 
      .Calendar table{ width:100%; border:0; } 
      .Calendar table thead{ color:#acacac; background-color:#000; } 
      .Calendar table td { font-size:11px; padding:1px; } 
      #idCalendarPreYear{ cursor:pointer; float:left; padding-left:5px; } 
      #idCalendarPreMonth{ cursor:pointer; float:left; padding-left:15px; } 
      #idCalendarNextMonth{ cursor:pointer; float:right; padding-right:15px; } 
      #idCalendarNextYear{ cursor:pointer; float:right; padding-right:5px; } 
      #idCalendar td.onToday { font-weight:bold; color:#C60; } 
      #idCalendar td.onSelect { font-weight:bold; }
    </style>
    <script type="text/javascript">
		
			var object_get = function(id) {
				return "string" == typeof id ? document.getElementById(id) : id;
			};

			var Class = {
				create: function() {
					return function() {
						this.initialize.apply(this, arguments);
					}
				}
			}

			Object.extend = function(destination, source) {
				for (var property in source) {
					destination[property] = source[property];
				}
				return destination;
			}
			var Calendar = Class.create();
			Calendar.prototype = {
				initialize: function(container, options) {
					this.Container = object_get(container); 
					this.Days = []; 
					this.SetOptions(options);

					this.Year = this.options.Year;
					this.Month = this.options.Month;
					this.SelectDay = this.options.SelectDay ? new Date(this.options.SelectDay) : null;
					this.onSelectDay = this.options.onSelectDay;
					this.onToday = this.options.onToday;
					this.onFinish = this.options.onFinish;

					this.Draw();
				},

				SetOptions: function(options) {
					this.options = { 
						Year: new Date().getFullYear(),
						Month: new Date().getMonth(),
						SelectDay: null,
						onSelectDay: function() {},
						onToday: function() {},
						onFinish: function() {} 
					};
					Object.extend(this.options, options || {});
				},
				
				//previous month
				PreMonth: function() {
					var d = new Date(this.Year, this.Month - 1, 1);
					this.Year = d.getFullYear();
					this.Month = d.getMonth();
					this.Draw();
				},
				//next month
				NextMonth: function() {
					var d = new Date(this.Year, this.Month + 1, 1);
					this.Year = d.getFullYear();
					this.Month = d.getMonth();
					this.Draw();
				},
				//previous year
				PreYear: function() {
					var d = new Date(this.Year - 1, this.Month, 1);
					this.Year = d.getFullYear();
					this.Month = d.getMonth();
					this.Draw();
				},
				//next year
				NextYear: function() {
					var d = new Date(this.Year + 1, this.Month , 1);
					this.Year = d.getFullYear();
					this.Month = d.getMonth();
					this.Draw();
				},

				Draw: function() {
					var arr = [];
					for (var i = 1, monthDay = new Date(this.Year, this.Month+1, 0).getDate(); i <= monthDay; i++) {
						arr.push(i);
					}

					var frag = document.createDocumentFragment();

					this.Days = [];
					
					var row = document.createElement("tr");
					while (arr.length > 0) {
						var cell = document.createElement("td");
						cell.innerHTML = "&nbsp;";

						if (arr.length > 0) {
							var d = arr.shift();
							//cell.innerHTML = d;
							//cell.innerHTML = "<a  href='javascript:void(0);' onclick=\"alert('You choose: " + this.Year + "-" + (this.Month + 1) + "-" + d + ", and functions will run.');return ture;\">" + d + "</a>";
							cell.innerHTML = "<a  href='javascript:void(0);' onclick='on_day_selected(" + this.Year + ", " + (this.Month + 1) + ", " + d + ");return ture;'>" + d + "</a>";
							if (d > 0) {
								this.Days[d] = cell;
								if (this.IsSame(new Date(this.Year, this.Month, d), new Date())) {
									this.onToday(cell);
								}
								if (this.SelectDay && this.IsSame(new Date(this.Year, this.Month, d), this.SelectDay)) {
									this.onSelectDay(cell);
								}
							}
						}
						row.appendChild( cell );
					}
					frag.appendChild(row);

					while (this.Container.hasChildNodes()) {
						this.Container.removeChild(this.Container.firstChild);
					}

					this.Container.appendChild(frag);

					this.onFinish();
				},

				IsSame: function(d1, d2) {
					return (d1.getFullYear() == d2.getFullYear() && d1.getMonth() == d2.getMonth() && d1.getDate() == d2.getDate());
				}
			};
		</script>
		<div class="Calendar">
			<table cellspacing="0">
				<thead>
					<div id="idCalendarPreYear">&lt;&lt;</div>
					<div id="idCalendarPreMonth">&lt;</div>
					<div id="idCalendarNextYear">&gt;&gt;</div>
					<div id="idCalendarNextMonth">&gt;</div>
					<span id="idCalendarMonth"></span>, 
					<span id="idCalendarYear"></span> 
				</thead>
				<tbody id="idCalendar"></tbody>
			</table>
		</div>
		<script type="text/javascript">
				var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
				var cale = new Calendar("idCalendar", {
						SelectDay: new Date(),
						onSelectDay: function(o) {
								o.className = "onSelect";
						},
						onToday: function(o) {
								o.className = "onToday";
						},
						onFinish: function() {
							//object_get("idCalendarYear").innerHTML = "<a href=\"/\">" + this.Year + "<\a>";
							object_get("idCalendarYear").innerHTML = this.Year;
							//object_get("idCalendarMonth").innerHTML = "<a href=\"#\">" + months[this.Month] + "<\a>";
							object_get("idCalendarMonth").innerHTML = months[this.Month];
						}
				});

				object_get("idCalendarPreMonth").onclick = function() {
						cale.PreMonth();
				}
				object_get("idCalendarNextMonth").onclick = function() {
						cale.NextMonth();
				}
				object_get("idCalendarPreYear").onclick = function() {
						cale.PreYear();
				}
				object_get("idCalendarNextYear").onclick = function() {
						cale.NextYear();
				}
				function on_day_selected(year, month, day){
					var method = "post";
					var eventId = "calendarPOST";
					var data = "year=" + year + "&month=" + month + "&day=" + day;

					XMLHttp.sendRequest( method, eventId, data, function(xmlhttp){
						var jsonstring = xmlhttp.responseText;
						object_get("gallery_main").innerHTML=xmlhttp.responseText;
						var json = eval( "("+jsonstring+")" );
						var test = json.test;
						alert("ming.du" + test);
					});
				}
		</script>
  
		<style type="text/css">
			.top_float{
				width:35px; 
				height:35px; 
				z-index:90000;
				position: fixed;
				bottom:50px;
				right:0px;
				_position:absolute;
				_left:expression(eval(document.documentElement.scrollLeft+document.documentElement.clientWidth-this.offsetWidth)-(parseInt(this.currentStyle.marginLeft,10)||0)-(parseInt(this.currentStyle.marginRight,10)||0)-15);
				_top:expression(eval(document.documentElement.scrollTop+document.documentElement.clientHeight-this.offsetHeight-(parseInt(this.currentStyle.marginTop,10)||0)-(parseInt(this.currentStyle.marginBottom,10)||0))-50);
			}
			.top_float .is_top {width:33px;height:33px;border:1px solid #efefef;border-radius:50%;overflow:hidden;background-color:#efefef;background-repeat:no-repeat; background-position:center center;background-size:15px auto;position:fixed;right:30px;bottom:60px;background-image:url("/images/to_top_big.jpg");}
			.top_float .is_top:hover,.top_float .hover { 
				border:1px solid #999999;
				background-color:#ffffff;
			}
			.top_float .is_top:hover,.top_float .hover {
				border:1px solid #999999;
				background-color:#ffffff;
			}
			.top_float .top_show,.sidebar_float .top_show { display:none;}
			.top_float .arrow,.sidebar_float .arrow{
				position:absolute;
				border-left:12px solid #efefef;
				border-top:6px solid transparent;
				border-bottom:6px solid transparent;
				left:-17px;
				top:10px;
			}
			.top_float .ico_info_bg,.sidebar_float .ico_info_bg{
				background-color:#efefef;
				height:20px;
				line-height:20px;
				padding:5px 10px;
				color:#000;
				right:48px;
				top:1px;
				white-space: nowrap;
				border-radius:3px;
			}
			.absolute{position:absolute;}
			.border{ border:1px solid #dfdfdf;}
			.hand{ cursor:pointer;}
		</style>


		<div class="top_float" >
			<div class="is_top ie6-hover border hand handle" id="backTop" object="#bt_div" href="#">
				<div class="top_show" id="bt_div">
					<div class="arrow absolute"></div>
					<div class="ico_info_bg absolute">To Top</div>
				</div>
			</div>
		</div>
</div>

