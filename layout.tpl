%scripts=get('scripts', [])
%scripts[:0] = ["/static/jquery-2.0.1.min.js",
%				"/static/bootstrap/js/bootstrap.min.js",
%				"/static/d3.v3.min.js"]

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
  <link rel="stylesheet" type="text/css" href="/static/bootstrap/css/bootstrap.css" media="all" />
  <link rel="stylesheet" type="text/css" href="/static/bootstrap/css/bootstrap-responsive.css" media="all" />
  %for script in scripts:
  <script src="{{script}}"></script>
  %end
</head>
<body>

  <nav class="navbar navbar-default" role="navigation">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#">SAE</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li class="active">
          <a href="/enron/search">Enron</a>
        </li>
        <li class="active">
          <a href="/enron/network/">Network Analysis</a>
        </li>
        <li class="active">
          <a href="/enron/topic/">Topic Analysis</a>
        </li>
      </ul>
    </div>
    <!-- /.navbar-collapse -->
  </nav>
  <div class="container">
    %include
  </div>

</body>
</html>
