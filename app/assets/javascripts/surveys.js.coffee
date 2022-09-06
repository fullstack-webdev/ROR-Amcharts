$ ->

  $('#import_tie_on').live "click", ->
    if $(this).is(':checked')
      $('#tie_on_fields').addClass "hidden"
    else
      $('#tie_on_fields').removeClass "hidden"
