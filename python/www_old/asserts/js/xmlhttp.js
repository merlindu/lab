/*
 * XMLHttpRequest object pool
 * Copyright 2016 ming.du@sunmedia.com.cn
 */

XMLHttp = {
	XMLHttpRequestPool: [],

	getInstance: function() {
		for ( var i = 0; i < this.XMLHttpRequestPool.length; i ++ ) {
			if ( this.XMLHttpRequestPool[i].readyState == 0 || this.XMLHttpRequestPool[i].readyState == 4 ) {
				return this.XMLHttpRequestPool[i];
			}
		}
		this.XMLHttpRequestPool[this.XMLHttpRequestPool.length] = this.createXMLHttpRequest();
		return this.XMLHttpRequestPool[this.XMLHttpRequestPool.length - 1];
	},

	createXMLHttpRequest: function() {
		if ( window.XMLHttpRequest ) {
			var objXMLHttp = new XMLHttpRequest();
		} else {
			// 将Internet Explorer内置的所有XMLHTTP ActiveX控制设置成数组
			var MSXML = ['MSXML2.XMLHTTP.5.0', 'MSXML2.XMLHTTP.4.0', 'MSXML2.XMLHTTP.3.0', 'MSXML2.XMLHTTP', 'Microsoft.XMLHTTP'];
			// 依次对Internet Explorer内置的XMLHTTP控件初始化
			for ( var n = 0; n < MSXML.length; n ++ ) {
				try {
					// 如果可以正常创建XMLHttpRequest对象，使用break跳出循环
					var objXMLHttp = new ActiveXObject( MSXML[n] ); 
					break;
				} catch( e ) {
				}
			}
		}
		// Mozilla某些版本没有readyState属性
		if ( objXMLHttp.readyState == null ) {
			// 直接设置其readyState为0
			objXMLHttp.readyState = 0;
			// 对于那些没有readyState属性的浏览器，将load动作与下面的函数关联起来
			objXMLHttp.addEventListener( "load", function() {
				// 当从服务器加载数据完成后，将readyState状态设为4
				objXMLHttp.readyState = 4;
				if ( typeof objXMLHttp.onreadystatechange == "function" ) {
					objXMLHttp.onreadystatechange();
				}
			}, false );
		}
		return objXMLHttp;
	},

	sendRequest: function( method, eventId, data, callback ) {
		var url = "/ajax"
		var objXMLHttp = this.getInstance();
		var content = "EventId=" + eventId + "&" + data;
		method = method.toUpperCase();
		with( objXMLHttp ) {
			try {
				// 增加一个额外的randnum请求参数，用于防止IE缓存服务器响应
				if ( url.indexOf("?") > 0 ) {
					url += "&randnum=" + Math.random();
				} else {
					url += "?randnum=" + Math.random();
				}
				if ( method == "GET" ) {
					url += "&" + content;
				}
				open( method, url, true );
				setRequestHeader( "X-Requested-With","XMLHttpRequest" );
				if ( method == "POST" ) {
					send( content );
				} else if ( method == "GET" ) {
					send( null );
				}
				onreadystatechange = function() {
					//当服务器的相应完成，以及获得了正常的服务器响应时
					if ( objXMLHttp.readyState == 4 && (objXMLHttp.status == 200 || objXMLHttp.status == 304) ) {
						callback.call( null, objXMLHttp );
					}
				}
			} catch( e ) {
				alert( e );
			}
		}
	}
};