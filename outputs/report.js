$(function () {
    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            'background-color': '#fee',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    };
    var result_charts = $("#distribution .distItem");
    xticks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
    result = []
    $.each(result_charts, function(i) {
      var chart_data = [];
      $(this).find('td[data-hour]').each(function(){
        chart_data.push( [$(this).data("hour"), $(this).data("value")]);
      })
      result.push({label: $(this).find("td:first").text(), data: chart_data});
      });
      var options = {
          lines: { show: true },
          points: { show: true },
          xaxis: {
            ticks: xticks
          },
          legend : {
            margin: [-260, 0]
          },
          grid: { hoverable: true }
      };
      var previousPoint = null;
      $.plot($("#chart"), result, options);
      $("#chart").bind("plothover", function (event, pos, item) {
        if (item) {
            if (previousPoint != item.dataIndex) {
                previousPoint = item.dataIndex;
                $("#tooltip").remove();
                var x = item.datapoint[0],
                    y = item.datapoint[1].toFixed(2);
                showTooltip(item.pageX, item.pageY,
                            item.series.label + " from "+ x + ":00-"+ x + ":59 is " + y + "s");
            }
        }
        else {
            $("#tooltip").remove();
            previousPoint = null;
        }
      });
    });

