$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#client_name').autocomplete
    source: $('#client_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#client_name").val(ui.item.label)
        $("#client_id").val(ui.item.id)

  client_focused = false
  $('#client_name').focusin ->
    client_focused = true
    $('#client_name').removeClass 'ui-autocomplete-bad'
    $('#client_name').addClass 'ui-autocomplete-typing'
    $('#client_name').val('')
    $('#client_id').val('')

  $('#client_name').focusout ->
    if client_focused && $('#client_id').val() == ''
      $('#client_name').addClass 'ui-autocomplete-bad'
      if $('#client_name').val() == ''
        $('#client_name').removeClass 'ui-autocomplete-typing'

  $('#rig_name').autocomplete
    source: $('#rig_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#rig_name").val(ui.item.label)
        $("#rig_id").val(ui.item.id)

  rig_focused = false
  $('#rig_name').focusin ->
    rig_focused = true
    $('#rig_name').removeClass 'ui-autocomplete-bad'
    $('#rig_name').addClass 'ui-autocomplete-typing'
    $('#rig_name').val('')
    $('#rig_id').val('')

  $('#rig_name').focusout ->
    if rig_focused && $('#rig_id').val() == ''
      $('#rig_name').addClass 'ui-autocomplete-bad'
      if $('#rig_name').val() == ''
        $('#rig_name').removeClass 'ui-autocomplete-typing'


  $('.close-modal').live "click", ->
    popup = $(this).closest('.modal-popup-background')
    popup.css "visibility", "hidden"
    popup.find(".modal-content").children().remove()
    popup.height(0)
    return false

  $('#close_modal').live "click", ->
    if $('#map').length > 0
      $('#map').show()
    $('#modal_popup').css "visibility", "hidden"
    $('#modal_popup').find(".modal-content").children().remove()
    $('#modal_popup').height(0)
    return false

  $('#close_modal2').live "click", ->
    if $('#map').length > 0 && $('#modal_popup').css('visibility') == 'hidden'
      $('#map').show()
    $('#modal_popup2').css "visibility", "hidden"
    $('#modal_popup2').find(".modal-content").children().remove()
    $('#modal_popup2').height(0)
    return false


  $('#new_field_link').click ->
    if $('#job_district_id').val() != ''
      $(this).attr 'href', "/fields/new" + '?district_id=' + $('#district_id').val()
    else
      alert('Select a District First')

  $('.modal-popup-background').live "click", (e) ->
    if e.target.id == 'modal_popup'
      $(this).find('#close_modal').trigger "click"

  $('#new_well_link').click ->
    $(this).attr 'href', "/wells/new" + '?field_id=' + $('#job_field_id').val() + "&modal=true"

  if $('#job_district_id').val() == ''
    $('#job_field_id').attr "disabled", "disabled"
    $('#job_field_id').css "opacity", ".3"

  if $('#job_field_id').val() == ''
    $('#job_well_id').attr "disabled", "disabled"
    $('#job_well_id').css "opacity", ".3"

  if $('#job_segment_id').val() == ""
    $('#job_segment_id').attr "disabled", "disabled"
    $('#job_segment_id').css "opacity", ".3"

  if $('#job_product_line_id').val() == ""
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"

  #if $('#job_job_template_id').val() == ""
  #  $('#job_job_template_id').attr "disabled", "disabled"
  #  $('#job_job_template_id').css "opacity", ".3"

  $('#job_division_id').change ->
    $('#job_segment_id').attr "disabled", "disabled"
    $('#job_segment_id').css "opacity", ".3"
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    $('#job_segment_id').addClass "ajax-loading"
    if $('#job_division_id').val() != ''
      $.ajax '/divisions?division_id=' + $('#job_division_id').val(), dataType: 'script'

  $('#job_segment_id').change ->
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    $('#job_product_line_id').addClass "ajax-loading"
    if $('#job_segment_id').val() != '' && $('#job_segment_id').val() != '-1'
      $.ajax '/segments?segment_id=' + $('#job_segment_id').val(), dataType: 'script'

  $('#job_product_line_id').change ->
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    if $('#job_product_line_id').val() != ''
      $(this).closest('.content').find('.loading').removeClass "hidden"
      $.ajax '/product_lines?product_line_id=' + $('#job_product_line_id').val(), dataType: 'script'

  $('#job_job_template_id').change ->
    if $('#job_job_template_id').val() != ''
      $.ajax '/job_templates/' + $('#job_job_template_id').val(), dataType: 'script'

  $('#district_id').change ->
    if $('#district_id').val() != ''
      $('#job_field_id').removeAttr("disabled")
      $('#job_field_id').css "opacity", "1"
      $.ajax '/fields?district_id=' + $('#district_id').val(), dataType: 'script'

  $('#job_field_id').change ->
    if $('#job_field_id').val() != ''
      $('#job_well_id').removeAttr("disabled")
      $('#job_well_id').css "opacity", "1"
      $('#job_well_id').attr "disabled", "disabled"
      $('#job_well_id').css "opacity", ".3"
      $('#job_well_id').addClass "ajax-loading"
      $.ajax '/wells?field_id=' + $('#job_field_id').val(), dataType: 'script'


  if $('#job_district_id').val()
    $.ajax '/fields?district_id=' + $('#job_district_id').val(), dataType: 'script'


  $('.job-type-selection').live "click", ->
    $('.job-type-selection').removeClass('job-type-selected')
    $(this).addClass('job-type-selected')
    $val = $(this).attr('id').replace('job_template_', '')
    $('#job_job_template_id').removeAttr "disabled", "disabled"
    $('#job_job_template_id').val($val)
    $('.job-creating-part2').removeClass 'hidden'
    $('body').animate({scrollTop : $(document).height()}, 'slow');
    return false

  $('.tool-type-selection').live "click", ->
    if $(this).hasClass 'tool-type-selected'
      $(this).removeClass('tool-type-selected')
    else
      $(this).addClass('tool-type-selected')

    params = []
    $('.tool-type-selection').each ->
      if $(this).hasClass 'tool-type-selected'
        params.push($(this).attr('data-primary-tool'))

    $('.job-type-selection').each ->
      tools = $(this).attr('data-primary-tools').split('_')
      keep = true
      for param in params
        keep2 = false
        for tool in tools
          if param == tool
            keep2 = true
        if !keep2
          keep = false
          break
      if keep
        $(this).closest('.field').show()
      else
        $(this).closest('.field').hide()

    return false

  $('.form-loading-on-click').live "click", ->
#  $('.form-loading-on-click').live "click", ->
    if $(this).attr('data-form').length > 0
      data = $(this).attr('data-form')
      form = $('.form[data-form=' + data + ']')
      loading = $('.form-loading[data-form=' + data + ']')

      if form.height() > 400 && ($('#modal_popup').length == 0 || $('#modal_popup').css('visibility') == 'hidden')
        $('body').animate({scrollTop : form.position().top - 200},'slow');

      form.hide()
      loading.removeClass 'hidden'
      loading.find('.loading').removeClass 'hidden'

    else
      $('.loading').removeClass 'hidden'
      $('.form').hide()
      $('body').animate({scrollTop : 0},'slow');

  $('.ajax-form-loading-on-click').live "click", ->
    $('.ajax-loading').removeClass 'hidden'
    $('.ajax-form').hide()

  $('#show_tool_filter').live "click", ->
    $(this).addClass 'hidden'
    $('.tool-filter').removeClass 'hidden'
    return false