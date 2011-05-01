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
      var result_charts = {
        NoRequests: "Requests per day",
        Request:    "Average request duration (s)",
        View:       "Average view rendering time (s)",
        Db:         "Average database response time (s)",
        NoRequestsApi: "Requests per day API",
        RequestApi:    "Average request duration API (s)",
        ViewApi:       "Average view rendering time API (s)",
        DbApi:         "Average database response time API (s)"
      };

      for(key in result_charts) {
        var chart_data = [];
        var xticks = [];
        $.each($(".dayItem"+key+":nth-child(6n+1)"), function(){
            xticks.push([Date.parse($(this).data("day")[0]), $(this).data("day")[1]])
        });
        $.each($(".dayItem"+key), function(){
            chart_data.push( [Date.parse($(this).data("day")[0]), $(this).data("value")]);
        });
        var options = {
            lines: { show: true },
            points: { show: true },
            xaxis: {
              ticks: xticks
            },
            legend : {
              margin: [-280, 0]
            },
            grid: { hoverable: true }
        };
        var previousPoint = null
        $.plot($("#chart"+key), [{label: result_charts[key], data: chart_data}], options);
      }
      var combinded_result_charts = {
        ConPlacesShow: "Average response time for PlacesController#show (s)",
        ConCategoriesShow:   "Average database time for CategoriesController#show (s)",
      };
      var combinded_xticks = [];
      $.each($(".combined [data-day]:nth-child(6n+1)"), function(){
          combinded_xticks.push([Date.parse($(this).data("day")[0]), $(this).data("day")[1]])
      });
      var chart_data = [];
      for(key in combinded_result_charts) {
        var semi_chart_data = [];
        $.each($(".dayItem"+ key), function(){
          semi_chart_data.push( [Date.parse($(this).data("day")[0]), parseFloat($(this).data("value"))]);
        });
        chart_data.push({label: combinded_result_charts[key], data : semi_chart_data })
      }
      var previousPoint = null
      var options = {
          lines: { show: true },
          points: { show: true },
          xaxis: {
            ticks: combinded_xticks
          },
          //yaxis: {
          //  ticks: [0, 1, 2, 3, 4, 5]
          //},
          legend : {
            margin: [-360, 0]
          },
          grid: { hoverable: true }
      };
      $.plot($("#chartControllers"), chart_data, options);
      $(".chart").bind("plothover", function (event, pos, item) {
          if (item) {
              if (previousPoint != item.dataIndex) {
                  previousPoint = item.dataIndex;
                  $("#tooltip").remove();
                  var x = item.datapoint[0],
                      y = item.datapoint[1].toFixed(2);
                  var date = new Date(x);
                  showTooltip(item.pageX, item.pageY,
                              item.series.label + " from "+ date.getDate() + "-" + (date.getMonth() + 1) + "-" + date.getFullYear() + " is " + y);
              }
          }
          else {
              $("#tooltip").remove();
              previousPoint = null;
          }
      });

  });

