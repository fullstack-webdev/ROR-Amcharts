$ ->
  validate_graph = (self) ->
    graph_id = self.find('.amChart').data('id')
    if graph_id && DV_CHARTS[graph_id]
      DV_CHARTS[graph_id].validateData()
      DV_CHARTS[graph_id].validateNow()

  $('.drill-view-port').live 'swiperight', () ->
    if !(navigator.userAgent.match(/iPad;.*CPU.*OS 7_\d/i) && Math.abs(window.orientation) == 90)
      self = this
      $(self).hide 'slide', {direction: 'right'}, () ->
        $(self).parent().find('.drill-view-chart').show()
        validate_graph $(self).parent().find('.drill-view-chart')

  $('.drill-view-chart:not(.mdv-slide)').live 'swipeleft', () ->
    if !(navigator.userAgent.match(/iPad;.*CPU.*OS 7_\d/i) && Math.abs(window.orientation) == 90)
      self = this
      $(self).hide 'slide', {direction: 'left'}, () ->
        $(self).parent().find('.drill-view-port').show()

  $('.drill-view-chart.mdv-slide').live 'swipeleft', () ->
    if !(navigator.userAgent.match(/iPad;.*CPU.*OS 7_\d/i) && Math.abs(window.orientation) == 90)
      self = this
      $(self).hide 'slide', {direction: 'left'}, () ->
        if $(self).next().length
          $(self).next().show()
          validate_graph $(self).next()
        else
          $(self).parent().children(":first").show()
          validate_graph $(self).parent().children(":first")

  $('.drill-view-chart.mdv-slide').live 'swiperight', () ->
    if !(navigator.userAgent.match(/iPad;.*CPU.*OS 7_\d/i) && Math.abs(window.orientation) == 90)
      self = this
      $(self).hide 'slide', {direction: 'right'}, () ->
        if $(self).prev().length
          $(self).prev().show()
          validate_graph $(self).prev()
        else
          $(self).parent().children(":last").show()
          validate_graph $(self).parent().children(":last")

  window.onorientationchange = () ->
    if Math.abs(window.orientation) == 90
      $('.drill-view-port').show()
      $('.drill-view-chart').show()