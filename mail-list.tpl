<head>
    <title> mail timeline</title>
    <link rel="stylesheet" type="text/css" href="/static/bootstrap/css/bootstrap.min.css">
    <script type="text/javascript" src="/static/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/static/bootstrap/js/bootstrap-paginator.min.js"></script>
    <script type="text/javascript" src="/static/js/jquery.min.js"></script>
	<script type="text/javascript" src="/static/js/jquery.dataTables.js"></script>
    <!-- more information at: http://www.datatables.net/download/ -->
<script type="text/javascript" src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.js"></script>

<script type="text/javascript" src="/static/js/webtoolkit.scrollabletable.js"></script>
 <script class="jsbin" src="http://datatables.net/download/build/jquery.dataTables.nightly.js"></script>
<script class="jsbin" src="/static/js/FixedHeader.js"></script>
    <style>

             @import "/static/css/jquery.dataTables.css";
             @import "/static/css/demo_page.css";
			 @import "/static/css/demo_table_jui.css";
			 @import "/static/css/demo_table.css";
			 @import "/static/css/jquery.dataTables_themeroller.css";
             @import "/static/css/jquery-ui-1.8.4.custom.css";
            .dataTables_info
            { padding-top: 0; }
            .dataTables_paginate
            { padding-top: 0; }
            .css_right
            { float: right; }
            #example_wrapper .fg-toolbar
            { font-size: 0.8em }
            #theme_links span
            { float: left; padding: 2px 10px; }
            #example_wrapper
            { -webkit-box-shadow: 2px 2px 6px #c0c0c0;
                box-shadow: 2px 2px 6px #c0c0c0;
                border-radius: 5px; }
            #example tbody {
                border-left: 1px solid #f0f0f0;
                border-right: 1px solid #f0f0f0;
            }
            #example thead th:first-child
            { border-left: 1px solid #AAA; }
            #example thead th:last-child
            { border-right: 1px solid #AAA; }


         </style>
</head>

<form class="search form-search" method="get">
    <fieldset>


    </fieldset>
</form>


<div class="row-fluid">

 <!-- Table -->
  <div class="panel panel-default">
  
  <!-- Default panel contents -->
  <div class="panel-heading"><h2><legend><span class="glyphicon glyphicon-envelope"></span> Mail timeline of {{name}}</legend></div>
  Sorted by
 
 <ul class="nav nav-tabs">
  <li><a href="#Date" data-toggle="tab">Date</a></li>
  <li><a href="#Senders" data-toggle="tab">Senders</a></li>
  <li><a href="#Recipients" data-toggle="tab">Recipients</a></li>
</ul>

<!-- Tab panes -->
<div class="tab-content">
  <div class="tab-pane active" id="Date">
    %if len(results1)!= 0:
   <table cellpadding="0" cellspacing="0" border="0" class="display" id="t1">
                       <thead>
                     <tr class="active" >
                       
                        <th>Date</th>
                        <th>Subject</th>
                        <th>From</th>
                        <th>To</th>
                     </tr>
                    </thead>

                    <tbody>
                        %for x,item in enumerate(results1):
                        <tr>
                           
                            <td>{{item['date']}}</td>
                            <td><a href="{{item['link']}}">{{item['subject']}}</a></td>
                            <td>{{item['sender']}}</td>
                            <td>{{item['recipients']}}</td>
                        </tr>
                        %end
                    </tbody>

    </table>
    %end	

  </div>
  
  <div class="tab-pane" id="Senders">
  <div class="panel-group"  id="accordion">
    %for x,p in enumerate({{result2}}):
	<div class="panel panel-default">
        <div class="panel-heading">
            <div class="panel-title">
                <a href="#panel{{x}}" class="panel-toggle" data-toggle="collapse" data-parent="#accordion">
                    From:  <span class="badge badge-important">{{sender[x]}}</span>
                </a>
            </div>
        </div>
        <div id="panel{{x}}" class="panel-collapse collapse in">
            <div class="panel-body">
               
   <table cellpadding="0" cellspacing="0" border="0" class="display" id="t2">
                       <thead>
                     <tr class="active" >
                       
                        <th>Date</th>
                        <th>Subject</th>
                       
                        <th>To</th>
                     </tr>
                    </thead>

                    <tbody>
                        %for x,item in enumerate(p):
                        <tr>
                           
                            <td>{{item['date']}}</td>
                            <td><a href="{{item['link']}}">{{item['subject']}}</a></td>
                            
                            <td>{{item['recipients']}}</td>
                        </tr>
                        %end
                    </tbody>

    </table>
   
            </div>
        </div>
    </div>
	%end
	</div>
	
  </div>
  
  <div class="tab-pane" id="Recipients">
    <div class="panel-group"  id="accordion">
    %for x,p in enumerate({{result3}}):
	<div class="panel panel-default">
        <div class="panel-heading">
            <div class="panel-title">
                <a href="#panel{{x}}" class="panel-toggle" data-toggle="collapse" data-parent="#accordion">
                    To:  <span class="badge badge-important">{{recipient[x]}}</span>
                </a>
            </div>
        </div>
        <div id="panel{{x}}" class="panel-collapse collapse in">
            <div class="panel-body">
                
   <table cellpadding="0" cellspacing="0" border="0" class="display" id="t3">
                       <thead>
                     <tr class="active" >
                       
                        <th>Date</th>
                        <th>Subject</th>
                        <th>From</th>
                        
                     </tr>
                    </thead>

                    <tbody>
                        %for item in p:
                        <tr>
                           
                            <td>{{item['date']}}</td>
                            <td><a href="{{item['link']}}">{{item['subject']}}</a></td>
                            <td>{{item['sender']}}</td>
                           
                        </tr>
                        %end
                    </tbody>

    </table>
    
            </div>
        </div>
    </div>
	%end
	</div>
  </div>

 </div>




   </div>

</div>




</div>

<script type="text/javascript">
    $('.btn-analysis').click(function() {
        var query = $('.search-query', $(this).parent()).val();
        window.location = "topictrends?q=" + encodeURIComponent(query);
        return false;
    });
    $(document).ready(function() {
        $('.result-item .item-img img').one('error', function() {
            $(this).attr('src', 'http://static02.linkedin.com/scds/common/u/img/icon/icon_no_company_logo_100x60.png');
        });
    });
    $(document).ready(function(){
    $('#t1').dataTable(
	
         );
	});
	 $(document).ready(function(){
    $('#t2').dataTable(
	
         );
	});
	 $(document).ready(function(){
    $('#t3').dataTable(
	
         );
	});
	$('.collapse').collapse({
	toggle: true,parent:'#accordion'
	})
	$('.panel-heading').on('click', function () {
		var self = this;
		$(self).nextAll().eq(0).collapse("show");
	})
</script>

%rebase layout
