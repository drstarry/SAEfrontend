
 <link href="/static/bootstrap/css/bootstrap-responsive.css" rel="stylesheet" type="text/css"/>
 <link href="/static/bootstrap/css/bootstrap.css" rel="stylesheet" type="text/css"/>
 <script type="text/javascript" src="/static/js/jquery.js"></script>
<script type="text/javascript" src="/static/bootstrap/js/bootstrap.js"></script>
<script type="text/javascript" src="/static/bootstrap/js/collapse.js"></script>
<script type="text/javascript" src="/static/bootstrap/js/jquery.dataTables.js"></script>
<style type="text/css">

    form.form-inline {
        display: inline-block;
    }
</style>

<h2>{{subject}}</h2>

<div class="panel-group"  id="accordion">
    <div class="panel panel-default">
        <div class="panel-heading">
            <div class="panel-title">
                <a href="#panel1" class="panel-toggle" data-toggle="collapse" data-parent="#accordion">
                    From:
                    <span class="badge badge-important">{{s_sum}}</span>
                </a>
            </div>
        </div>
        <div id="panel1" class="panel-collapse collapse in">
            <div class="panel-body">{{sender}}</div>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <div class="panel-title">
                <a href="#panel2" class="panel-toggle" data-toggle="collapse" data-parent="#accordion">
                    To:
                    <span class="badge badge-important">{{r_sum}}</a>
                </div>
            </div>
            <div id="panel2" class="panel-collapse collapse in">
                <div class="panel-body">{{recipients}}</div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <div class="panel-title">Mail:</div>
            </div>

            <pre>{{body}}</pre>
        </div>

    </div>

</div>
<script>

$('.collapse').collapse({
  toggle: true,parent:'#accordion'
})
$('.panel-heading').on('click', function () {
    var self = this;
    $(self).nextAll().eq(0).collapse("show");
})
</script>

%rebase layout
