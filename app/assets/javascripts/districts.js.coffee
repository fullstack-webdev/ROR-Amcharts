

$ ->

  if $('#job_field_id').val() == ''
    $('#district_state_id').attr "disabled", "disabled"
    $('#district_state_id').css "opacity", ".3"

  $('#district_country_id').change ->
    $('#district_state_id').removeAttr("disabled")
    $('#district_state_id').css "opacity", "1"
    $.ajax '/countries/' + $('#district_country_id').val(), dataType: 'script'


  $('#district_name_id').keyup ->
    $.ajax '/districts?master=false&search=' + $(this).val(), type: 'get', dataType: 'script'