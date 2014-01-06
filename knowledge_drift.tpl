<link rel="stylesheet" type="text/css" href="/static/css/topictrend.css">
<link rel="stylesheet" type="text/css" href="/static/css/frame.css">

<div id="chart" class="pull-left">
  <script src="/static/js/d3.layout.cloud.js"></script>
  <script src="/static/js/sankey.js"></script>
  <script src="/static/js/topictrend.js"></script>
  <div class="modal-loading"></div>
</div>
<div id="bottom-box" ></div>

<div id="right-box" style="overflow:auto; width:300px;">
	<ul class="nav nav-tabs" id="nav" style="display:none">
  	<li class="active" ><a href="#" id="first-three">Current Hotspot</a></li>
  	<li><a href="#" id="revert">Overall</a></li>
	</ul>
</div>

%rebase layout