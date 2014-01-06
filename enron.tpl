<style>

.node circle {
  fill: #fff;
  stroke: darkgray;
  stroke-width: 1.5px;
}

.node {
  font: 10px sans-serif;
}

.link {
  fill: none;
  stroke: #ccc;
  stroke-width: 1.5px;
}


/*path.link {
  fill: none;
  stroke: #666;
  stroke-width: 1.5px;
}*/

marker#licensing {
  fill: green;
}

path.link.licensing {
  stroke: green;
}

path.link.resolved {
  stroke-dasharray: 0,2 1;
}

circle {
  fill: #ccc;
  stroke: lightgray;
  stroke-width: 1.5px;
}

text {
  font: 10px sans-serif;
  pointer-events: none;
}

text.shadow {
  stroke: #fff;
  stroke-width: 3px;
  stroke-opacity: .8;
}
.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.bar {
  fill: orange;
}

.bar:hover {
  fill: orangered ;
}

.x.axis path {
  display: none;
}

.d3-tip {
  line-height: 1;
  font-weight: bold;
  padding: 12px;
  background: rgba(0, 0, 0, 0.8);
  color: #fff;
  border-radius: 2px;
}

/* Creates a small triangle extender for the tooltip */
.d3-tip:after {
  box-sizing: border-box;
  display: inline;
  font-size: 10px;
  width: 100%;
  line-height: 1;
  color: rgba(0, 0, 0, 0.8);
  content: "\25BC";
  position: absolute;
  text-align: center;
}

/* Style northward tooltips differently */
.d3-tip.n:after {
  margin: -1px 0 0 0;
  top: 100%;
  left: 0;
}

</style>
<h1>Network Analysis</h1>
<h4>1.Social Role Analysis</h4>
<h4>2.Community Detection</h4>
<h4>3.Visualization</h4>
<div id="browser" class="container">
    <div id="role" class="span6"></div>
    <div id="email" class="span5"></div>

</div>
<script src="http://labratrevenge.com/d3-tip/javascripts/d3.tip.min.js"></script>
<script>

var diameter = 600;

var color = d3.scale.category20();

var tree = d3.layout.tree()
    .size([360, diameter / 2 - 50])
    .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

var diagonal = d3.svg.diagonal.radial()
    .projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });

var svg = d3.select("#role").append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
    .append("g")
    .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");



var w = 500,
    h = 500;


var email_svg = d3.select("#email").append("svg:svg")
    .attr("width", w)
    .attr("height", h);

var position = null;
d3.json("/enron/network/position/", function(data){
  position = data["role"];
  pid = data["pid"];

  var tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) {
    return "<strong>Frequency:</strong> <span style='color:red'>" + d.pos + "</span>";
  })
  svg.call(tip);

  d3.json("/static/employee.json", function(error, root) {
    var nodes = tree.nodes(root),
        links = tree.links(nodes);

    var link = svg.selectAll(".link")
        .data(links)
      .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal);

    var node = svg.selectAll(".node")
        .data(nodes)
      .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })


    node.append("circle")
        .attr("r", 7)      
        .style("fill", function(d){
          var pos = position[d.name];
          if(pos == null){
            pos = "";
          }        
          d.pos = pos;
          return color(pos);
        })
        .on("mouseenter", function(d){
          d3.select(this).style("fill", "darkgray");
          tip.show(d);
        })
        .on("mouseout", function(d){
          d3.select(this).style("fill", function(d){
            return color(d.pos);
          })
          tip.hide();
        })
        .on("click", function(d){
          d3.json("/enron/network/graph/"+pid[d.name], function(out){
              email_svg.remove();
              email_svg = d3.select("#email").append("svg:svg")
                  .attr("width", w)
                  .attr("height", h);
              var profiles = out["profiles"]
              var emails = out["emails"]
              var nodes = {};
              links = [];

              emails.sort(function(a,b){
                return a.messages - b.messages;
              })

              var count = 0
              emails.forEach(function(d) {
                if(count < 100){
                  links.push(d);
                  count++;
                }
                else{
                  return;
                }
              });
              // Compute the distinct nodes from the links.
              links.forEach(function(link) {
                link.source = link.sender;
                link.target = link.recipient;
                link.source = nodes[link.source] || (nodes[link.source] = {name: link.source, id: link.sid});
                link.target = nodes[link.target] || (nodes[link.target] = {name: link.target, id: link.rid});
                link.type=link.messages;
              });

              var force = d3.layout.force()
                  .nodes(d3.values(nodes))
                  .links(links)
                  .size([w, h])
                  .linkDistance(60)
                  .charge(-300)
                  .on("tick", tick)
                  .start();

              // Per-type markers, as they don't inherit styles.
              email_svg.append("svg:defs").selectAll("marker")
                  .data(["suit", "licensing", "resolved"])
                .enter().append("svg:marker")
                  .attr("id", String)
                  .attr("viewBox", "0 -5 10 10")
                  .attr("refX", 15)
                  .attr("refY", -1.5)
                  .attr("markerWidth", 6)
                  .attr("markerHeight", 6)
                  .attr("orient", "auto")
                .append("svg:path")
                  .attr("d", "M0,-5L10,0L0,5");

              var path = email_svg.append("svg:g").selectAll("path")
                  .data(force.links())
                .enter().append("svg:path")
                  .attr("class", function(d) { return "link " + d.type; })
                  .attr("marker-end", function(d) { return "url(#" + d.type + ")"; });

              var circle = email_svg.append("svg:g").selectAll("circle")
                  .data(force.nodes())
                .enter().append("svg:circle")
                  .attr("r", 6)
                  .style("fill", function(d){
                    return color(profiles[d.id][7]);
                  })
                  .call(force.drag);

              var text = email_svg.append("svg:g").selectAll("g")
                  .data(force.nodes())
                .enter().append("svg:g");

              // A copy of the text with a thick white stroke for legibility.
              text.append("svg:text")
                  .attr("x", 8)
                  .attr("y", ".31em")
                  .attr("class", "shadow")
                  .text(function(d) { return d.name; });

              text.append("svg:text")
                  .attr("x", 8)
                  .attr("y", ".31em")
                  .text(function(d) { return d.name; });

              // Use elliptical arc path segments to doubly-encode directionality.
              function tick() {
                path.attr("d", function(d) {
                  var dx = d.target.x - d.source.x,
                      dy = d.target.y - d.source.y,
                      dr = Math.sqrt(dx * dx + dy * dy);
                  return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
                });

                circle.attr("transform", function(d) {
                  return "translate(" + d.x + "," + d.y + ")";
                });

                text.attr("transform", function(d) {
                  return "translate(" + d.x + "," + d.y + ")";
                });
              }
          })
        });

    node.append("text")
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .text(function(d) { return d.name; });
  });

})

  // d3.json("/static/data.json", function(data){
  //     
  //   })

d3.select(self.frameElement).style("height", diameter - 150 + "px");

</script>

%rebase layout