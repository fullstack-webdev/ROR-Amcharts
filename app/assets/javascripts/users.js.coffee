
$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#district_name').autocomplete
    source: $('#district_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#district_name").val(ui.item.label)
        $("#district_id").val(ui.item.id).trigger("change")

  district_focused = false
  $('#district_name').focusin ->
    district_focused = true
    $('#district_name').removeClass 'ui-autocomplete-bad'
    $('#district_name').addClass 'ui-autocomplete-typing'
    $('#district_name').val('')
    $('#district_id').val('')

  $('#district_name').focusout ->
    if district_focused && $('#district_id').val() == ''
      $('#district_name').addClass 'ui-autocomplete-bad'
      if $('#district_name').val() == ''
        $('#district_name').removeClass 'ui-autocomplete-typing'
