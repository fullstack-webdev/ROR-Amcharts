$ ->

  update_filter = () ->
    $('#overview_loading').removeClass 'hidden'
    $('#overview_trays').hide()
    section = "company"
    if document.location.hash != ''
      section = document.location.hash.replace('#', '')
    $.ajax '/overview/' + "?section=" + section +
      "&division_id=" + $("#division_filter_id").val() +
      "&user_id=" + $("#person_filter_id").val() +
      "&district_id=" + $("#district_filter_id").val() +
      "&time=" + $("#time_filter_id").val() +
      "&rating=" + $("#rating_filter_id").val() +
      "&failure_level=" + $("#failure_filter_id").val(),
      type: 'get', dataType: 'script'

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#person_filter').autocomplete
    source: $('#person_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#person_filter").val(ui.item.label)
      $("#person_filter_id").val(ui.item.id)
      update_filter()

  $('#person_filter').change ->
    $("#person_filter_id").val('')

  $('#division_filter').autocomplete
    source: $('#division_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#division_filter").val(ui.item.division_type + " " + ui.item.name)
      $("#division_filter_id").val(ui.item.division_type + "/////" + ui.item.id)
      update_filter()

  $('#district_filter').autocomplete
    source: $('#district_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#district_filter").val(ui.item.name)
      $("#district_filter_id").val(ui.item.id)
      update_filter()

  $('.clear-filter-link').click ->
    $("#division_filter").val('')
    $("#division_filter_id").val('')
    $("#district_filter").val('')
    $("#district_filter_id").val('')
    $("#person_filter").val('')
    $("#person_filter_id").val('')
    update_filter()
    return false

  $('#show_hide_overview_filters').click ->
    if $(this).attr('data-showing') == "basic"
      $(this).attr('data-showing', 'advanced')
      $(this).text("Hide")
      $('#overview_filters').removeClass 'hidden'
    else
      $(this).attr('data-showing', 'basic')
      $(this).text("Show")
      $('#overview_filters').addClass 'hidden'
    return false

  $('.overview-time-filters').change ->
    $("#time_filter_id").val($(this).find('option:selected').val())
    update_filter()

  $('.overview-time-filter').click ->
    $('.overview-time-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#time_filter_id").val($(this).data('time'))
    update_filter()
    return false

  $('.overview-rating-filter').click ->
    $('.overview-rating-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#rating_filter_id").val($(this).data('rating'))
    update_filter()
    return false

  $('.overview-failure-filter').click ->
    $('.overview-failure-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#failure_filter_id").val($(this).data('failure'))
    update_filter()
    return false

  $('.wells-overview-toggle div').live 'click', ->
    value = $(this).data('view-mode')
    $('.wells-overview-toggle div').removeClass 'active'
    $(this).addClass 'active'
    $('#overview_jobs .wells-overview').hide()
    $('#overview_jobs .wells-overview.overview-'+value).show()
    return false

  return false
