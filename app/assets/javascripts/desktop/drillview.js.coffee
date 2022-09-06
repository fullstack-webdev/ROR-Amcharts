$ ->
  window.DvChartCursor = (cursor_id, chart_id, dv_chart, update_dv) ->
    myCursor = undefined
    timer = undefined
    chartCursor = new AmCharts.ChartCursor()
    chartCursor.addListener "moved", (event) ->
      yAxis = dv_chart.getValueAxisById('depth_axis')
      yValue = AmCharts.roundTo(yAxis.coordinateToValue(event.y - yAxis.axisY), 2)
      $('#' + cursor_id).css('top', event.y)
      if myCursor != yValue
        update_dv(yValue)
        myCursor = yValue
    chartCursor.cursorAlpha = 0;
    chartCursor.zoomable = false;
    dv_chart.addChartCursor(chartCursor)

    $('#' + chart_id).on 'mouseenter', ->
      $('#' + cursor_id).show()
      update_dv myCursor
      return
    $('#' + chart_id).on 'mouseleave', ->
      $('#' + cursor_id).hide()
      timer = setTimeout((->
        update_dv -1
      ), 0)
    $('#' + cursor_id).on 'mouseover', () ->
      clearTimeout(timer)
