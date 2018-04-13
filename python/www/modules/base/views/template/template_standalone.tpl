<!DOCTYPE html>
<html lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0"/>
  <title>Platform Home</title>
  <link rel="icon" type="image/ico" href="/images/favicon.ico">
  <link href="/iconfont/material-icons.css" rel="stylesheet">
  <link href="/css/materialize.min.css" type="text/css" rel="stylesheet" media="screen,projection"/>
  <link href="/css/style.css" type="text/css" rel="stylesheet" media="screen,projection"/>
</head>
<body>
  <!-- Dropdown Structure -->
  <ul id='dropdown_tream' class='dropdown-content'>
    <li><a href="/media/playback"><i class="material-icons">video_library</i>Library</a></li>
    <li class="divider"></li>
    <li><a href="/media/real"><i class="material-icons">videocam</i>Real</a></li>
  </ul>
  <ul id='dropdown_tream_mobile' class='dropdown-content light-blue lighten-5'>
    <li><a href="/media/playback"><i class="material-icons">video_library</i>Library</a></li>
    <li class="divider"></li>
    <li><a href="/media/real"><i class="material-icons">videocam</i>Real</a></li>
  </ul>
  <nav class="light-blue lighten-1" role="navigation">
    <div class="nav-wrapper container">
      <a href="#!" class="brand-logo">iCatchTek V50</a>
      <ul class="right hide-on-med-and-down">
        <li><a href="/">Home<i class="material-icons left">home</i></a></li>
        <li class="divider"></li>
        <li><a href="/network">Network<i class="material-icons left">wifi</i></a></li>
        <li class="divider"></li>
        <li><a class='dropdown-trigger' href='#!' data-target='dropdown_tream'><i class="material-icons left">ondemand_video</i>Streaming<i class="material-icons right">arrow_drop_down</i></a></li>
        <li><a href="/gpio">Peripheral<i class="material-icons left">link</i></a></li>
        <li><a href="/settings">Settings<i class="material-icons left">settings</i></a></li>
      </ul>
      <ul id="nav-mobile" class="sidenav">
        <li class="orange"><div class="icat-logo orange"></div></li>
        <li><a href="/">Home<i class="material-icons left">home</i></a></li>
        <li class="divider"></li>
        <li><a href="/network">Network<i class="material-icons left">wifi</i></a></li>
        <li class="divider"></li>
        <li><a class='dropdown-trigger' href='#' data-target='dropdown_tream_mobile'><i class="material-icons left">ondemand_video</i>Streaming<i class="material-icons right">arrow_drop_down</i></a></li>
        <li class="divider"></li>
        <li><a href="/gpio">Peripheral<i class="material-icons left">link</i></a></li>
        <li class="divider"></li>
        <li><a href="/settings">Settings<i class="material-icons left">settings</i></a></li>
      </ul>
      <a href="#" data-target="nav-mobile" class="sidenav-trigger"><i class="material-icons">menu</i></a>
    </div>
  </nav>

  <div class="section no-pad-bot" id="index-banner">
    <div class="container">
      <br><br>
      <h1 class="header center orange-text">Standalone Template Page</h1>
      <br><br>

    </div>
  </div>


  <div class="container">
    <div class="section">

      <!--   Icon Section   -->
      <div class="row">
        <div class="col s12 m4">
          <div class="icon-block">
            <h2 class="center light-blue-text"><i class="material-icons">flash_on</i></h2>
            <h5 class="center">Speeds up development</h5>

            <p class="light">We did most of the heavy lifting for you to provide a default stylings that incorporate our custom components. Additionally, we refined animations and transitions to provide a smoother experience for developers.</p>
          </div>
        </div>

        <div class="col s12 m4">
          <div class="icon-block">
            <h2 class="center light-blue-text"><i class="material-icons">group</i></h2>
            <h5 class="center">User Experience Focused</h5>

            <p class="light">By utilizing elements and principles of Material Design, we were able to create a framework that incorporates components and animations that provide more feedback to users. Additionally, a single underlying responsive system across all platforms allow for a more unified user experience.</p>
          </div>
        </div>

        <div class="col s12 m4">
          <div class="icon-block">
            <h2 class="center light-blue-text"><i class="material-icons">settings</i></h2>
            <h5 class="center">Easy to work with</h5>

            <p class="light">We have provided detailed documentation as well as specific code examples to help new users get started. We are also always open to feedback and can answer any questions a user may have about Materialize.</p>
          </div>
        </div>
      </div>

    </div>
    <br><br>
  </div>

  <footer class="page-footer footer-copyright blue">
    <div class="container center">
      ©2018  <a class="orange-text text-lighten-1" href="http://www.icatchtek.com">iCatch Technology, Inc.</a> All Rights Reserved. Framework based on <a class="orange-text text-lighten-4" href="http://materializecss.com">Materialize</a>.
    </div>
  </footer>
  <script src="/js/jquery-1.12.3.min.js"></script>
  <script src="/js/materialize.min.js"></script>
  <script type="text/javascript">
    $( document ).ready(function(){
      $('.dropdown-trigger').dropdown();
      $('.sidenav').sidenav();
    });
  </script>

</body>
</html>
