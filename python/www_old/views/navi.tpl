<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
	<div class="navbar-header">
	  	<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#example-navbar-collapse">
	     	<span class="sr-only">Toggle navigation</span>
	    	<span class="icon-bar"></span>
	     	<span class="icon-bar"></span>
	     	<span class="icon-bar"></span>
	  	</button>
	  	<span class="navbar-brand icat-nav-logo">iCatchtek</span>
	  <!--a class="navbar-brand"href="javascript:void();" style='color:#FFF;'></a-->
	</div>

   <div class="collapse navbar-collapse"  id="example-navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="/">Home</a></li>
		<li><a href="/network">Network</a></li>
		<li><a href="/net_static">Static</a></li>
		<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="">Streaming</a>
			<ul class="dropdown-menu">
				<li><a href="/playback">Play Back</a></li>
				<li><a href="/real">Real Video</a></li>
			</ul>
		</li>
		<li><a href="/gpio">Peripheral</a></li>
		%import icatch_funcs 
		%if(icatch_funcs.uci_get('httpstation.@httpstation[0].authentication') == '1'):
		<li><a href="/logout">Logout</a></li>
		%end
	</ul>
   </div>  
</nav>
