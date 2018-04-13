/*!
 * XMLHttpRequest object pool
 * Copyright 2016-2018 ming.du@sunmedia.com.cn
 */
XMLHttp = {
	XMLHttpRequestPool: [],

	getInstance:function(){
		for(var i = 0; i < this.XMLHttpRequestPool.length; i ++){
			if(this.XMLHttpRequestPool[i].readyState == 0 
					|| this.XMLHttpRequestPool[i].readyState == 4){
				return this.XMLHttpRequestPool[i];
			}
		}
		this.XMLHttpRequestPool[this.XMLHttpRequestPool.length] 
			= this.createXMLHttpRequest();
		return this.XMLHttpRequestPool[this.XMLHttpRequestPool.length - 1];
	},

	createXMLHttpRequest:function(){
		if(window.XMLHttpRequest){
			var objXMLHttp = new XMLHttpRequest();
		}else{
			var MSXML = ['MSXML2.XMLHTTP.5.0', 'MSXML2.XMLHTTP.4.0', 
				'MSXML2.XMLHTTP.3.0', 'MSXML2.XMLHTTP', 'Microsoft.XMLHTTP'];
			for(var n = 0; n < MSXML.length; n ++){
				try{
					var objXMLHttp = new ActiveXObject(MSXML[n]); 
					break;
				}catch(e){}
			}
		}
		if(objXMLHttp.readyState == null){
			objXMLHttp.readyState = 0;
			objXMLHttp.addEventListener("load", function (){
				objXMLHttp.readyState = 4;
				if(typeof objXMLHttp.onreadystatechange == "function"){
					objXMLHttp.onreadystatechange();
				}
			}, false);
		}
		return objXMLHttp;
	},

	sendRequest: function( url, method, eventId, data, callback ){
		var objXMLHttp = this.getInstance();
		var content = "EventId=" + eventId + "&" + data;
		method = method.toUpperCase();
		with(objXMLHttp){
			try{
				if(url.indexOf("?") > 0){
					url += "&randnum=" + Math.random();
				}else{
					url += "?randnum=" + Math.random();
				}
				if(method == "GET"){
					url += "&" + content;
				}

				open(method, url, true);

				setRequestHeader("X-Requested-With","XMLHttpRequest");

				if (method == "POST"){
					send( content );
				}else if(method == "GET"){
					send(null);
				}

				onreadystatechange = function(){
					if( objXMLHttp.readyState == 4 
							&& (objXMLHttp.status == 200 || objXMLHttp.status == 304) ){
						callback.call(null , objXMLHttp);
					}
				}
			}catch(e){
				alert(e);
			}
		}
	}
};
