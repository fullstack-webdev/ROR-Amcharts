$ ->

  $('#jump_to_district_select').change ->
    selected = $(this).find('option:selected')
    if selected.val() != ''
      window.location = "/inventory?district=" + $(this).find('option:selected').val()

  $('#district_id').change ->
    if $(this).closest('.district-jump').length > 0
      window.location = "/inventory?district=" + $(this).val()
