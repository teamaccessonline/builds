<?php
$headers = apache_request_headers();
?>

<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>
<head>
  <title>Application Headers</title>
  <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
  <meta http-equiv='X-UA-Compatible' content='IE=edge' /> <!-- Make IE play nice -->
  <meta name='viewport' content='width=device-width, user-scalable=yes'/>
  <link rel='stylesheet' href='./css/main.css'>
</head>
<body>
  <div class='header'>
    <div class='header-content'>
      <div class='header-image'><img src='./img/app1_icon.png' height='75px'></div>
      <div class='header-title'>Application Headers</div>
      <div class='header-subtitle'>Demo Application</div>
    </div>
  </div>
  <div id="contentWrapper">
    <div id="mainCentered"><center>
        <table style='table-layout:fixed;' width='95%' border='1'>
        <?php
          foreach ($headers as $header => $value) {
            echo "<tr><td style='width: 20%; word-wrap:break-word;'>".$header."</td><td style='width: 80%; word-wrap:break-word;'>".htmlspecialchars($value)."</td></tr>";
          }
        ?>
        </table></center> 
    </div>
  </div>
</body>
</html>
