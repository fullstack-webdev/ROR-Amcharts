$ ->

  $(".submit-enter").keypress (e) ->
    if e.which is 13
      $(this).blur()
      $(this).closest("form").find("input[type=submit]").trigger('click')


  $('#checkbox_override_date').click ->
    if $('.date-fields').hasClass 'hidden'
      $('.date-fields').removeClass 'hidden'
    else
      $('.date-fields').addClass 'hidden'

  $('.timepicker').timepicker()
