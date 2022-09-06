$ ->
  $('.range-validator').live "keyup", ->
    value = parseFloat($(this).val())
    if value < parseFloat($(this).attr('data-minimum')) || value > parseFloat($(this).attr('data-maximum'))
      $(this).addClass 'ui-autocomplete-bad'
    else
      $(this).removeClass 'ui-autocomplete-bad'

    any = false
    $('.range-validator').each ->
      if $(this).hasClass 'ui-autocomplete-bad'
        any = true

    if any
      $('#survey_out_of_range').removeClass 'hidden'
    else
      $('#survey_out_of_range').addClass 'hidden'