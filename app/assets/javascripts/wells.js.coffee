$ ->

  bad_well = (box) ->
    box.addClass 'ui-autocomplete-bad'
    alert("Invalid Well Location. Please format like:\n'28 25 43.426 N, 99 30 53.148 W'\nor '28.42, -99.51'")

  $('.map-latlong-text-entry').live "change", ->
    latlong = $(this).val().trim()
    if latlong.length > 0
      parts = latlong.split(',')
      if parts.length != 2
        return bad_well $(this)
      else
        for i in [0...2]
          sub_parts = parts[i].trim().split(' ')
          if sub_parts == 0
            return bad_well $(this)
          else if sub_parts.length == 1
            if parseFloat(sub_parts[0]) > 360 || parseFloat(sub_parts[0]) < -360
              return bad_well $(this)
          else if sub_parts.length == 4
            x = 2
          else
            return bad_well $(this)


  $('.map-latlong-text-entry').live "keyup", ->
    if $(this).hasClass 'ui-autocomplete-bad'
      $(this).removeClass 'ui-autocomplete-bad'
    if $(this).val().length > 0
      $('.map-latlong-link').removeClass 'hidden'
    else
      $('.map-latlong-link').addClass 'hidden'

  $('.map-latlong-link').live "click", ->
    $(this).attr 'href', 'http://maps.google.com/maps?z=10&q=' + $('.map-latlong-text-entry').val()

  if $('#offshore_checkbox').is(':checked')
    $('#offshore_fields').css('display', 'inline')

  $('#offshore_checkbox').live "click", ->
    if $(this).is(':checked')
      $('#offshore_fields').css('display', 'inline')
    else
      $('#offshore_fields').css('display', 'none')

  $('#expand_well_details').click ->
    $('#expand_well_details').hide()
    $('.well-details').removeClass 'hidden'
    return false

  $('.job-type-select').change ->
    division = $(this).val()

    count = 0
    $('.job-link').each ->
      id = $(this).attr("id").replace('division_', '')
      if division == '0' || id == division
        $(this).show()
        count = count + 1
      else
        $(this).hide()

    $('#jobs_count_container').removeClass 'hidden'
    $('#jobs_count').text(count)


  $('.well-update-field').live "change", ->
    if $(this).val().length > 0
      $.ajax '/wells/' + $(this).attr("data-id"),
        data: {"update_field": "true", "field": $(this).attr("data-field"), "value": $(this).val()},
        type: 'put',
        dataType: 'script'




