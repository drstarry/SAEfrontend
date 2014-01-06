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
  <div class="panel-heading"><h2><legend>Mail timeline of {{name}}</legend></div>
       
    %if len(results)!= 0:
   <table cellpadding="0" cellspacing="0" border="0" class="display" id="example">
                       <thead>
                     <tr class="active" >
                       
                        <th>Date</th>
                        <th>Subject</th>
                        <th>From</th>
                        <th>To</th>
                     </tr>
                    </thead>

                    <tbody>
                        %for x,item in enumerate(results):
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
    $('#example').dataTable(
	
         );
});
</script>

%rebase layout
