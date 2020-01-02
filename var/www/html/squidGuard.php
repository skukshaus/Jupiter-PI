<html>
<head>
	<title>Proxy Fehler</title>
	<style>
		body {
			font-family: "comic sans ms";
			background: #222;
			font-size: 20px;
		}
		div.content {
			background: #fff;
			width: 100%;
			max-width: 960px;
			height: 40vh;
			min-height: 300px;
			margin: 20vh auto;
		}
		div.header {
			background: darkred;
			padding: 10px 20px;
			color: white;
		}
		span.title {
			font-size: 32px;
			font-weight: bold;
		}
		span.descr {
			font-size: 32px;
		}
		div.main {
			padding: 10px 20px;
		}
		span.ahref {
			color: blue;
			text-decoration: underline;
		}
		span.target {
			color: red;
			font-style: italic;
		}
		div.footer {
			color: #999;
			font-size: 14px;
			font-style: italic;
		}
	</style>
</head>
<body>

<div class="content">
	<div class="header">
		<span class="title">FEHLER:</span>
		<span class="descr">Die angeforderte Website wurde blockiert</span>
	</div>
	<div class="main">
		<strong>URL:</strong><br/>
		<span class="ahref"><?= $_GET['u'] ?></span><br/>
		<br/>
		<strong>Grund:</strong><br/>
		Die Website befindet sich auf der Schwarzen Liste: <span class="target"><?= $_GET['t']?></span><br/>
		<br/>
		<hr />
		<div class="footer">
			<strong>Client:</strong>
			<span><?= $_GET['a'] ?>@<?= $_GET['s'] ?></span>
			<strong>Zeit:</strong>
			<span><?= date('r') ?></span>
		</div>
	</div>
</div>
</body>
</html>