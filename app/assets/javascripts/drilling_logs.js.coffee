$ ->

  $('#activity_code_select').live "change", ->
    current_value = $(this).find('option:selected').val()
    if current_value == '4' || current_value == '13'
      $('#survey_entry').removeClass 'hidden'
    else
      $('#survey_entry').addClass 'hidden'
    return false


  $('#drilling_log_filter').live "change", ->
    data_id = $(this).attr('data-id')
    selection = $(this).find('option:selected').val()
    $('.log-entry-hidden').addClass 'hidden'
    if selection == 'recent'
      $('.log-entry-group').each ->
        $(this).hide()
      $('.log-entry-group:last').show()
      count = $('.log-entry-group:last').find('.drilling-log-entry').length - 5
      if count < 0
        count = 0
      $('.log-entry-group:last').find('.log-entry-hidden').text('' + (count) + ' previous entries this day...').removeClass 'hidden'
      $('.log-entry-group:last').find('.drilling-log-entry').each ->
        $(this).hide()
      $('.log-entry-group:last').find('.drilling-log-entry').slice(-5).each ->
        $(this).show()
    else if selection == 'all'
      $('.log-entry-group').each ->
        if $(this).attr('data-loaded') == "false"
          data_date = $(this).attr('data-date')
          $.ajax "/drilling_logs/#{data_id}?section=log2&date=#{data_date}", type: "get", dataType: "script"
        $(this).show()
      $('.drilling-log-entry').each ->
        $(this).show()
    else
      $('.log-entry-group').each ->
        if $(this).attr('data-date') == selection
          if $(this).attr('data-loaded') == "false"
            $.ajax "/drilling_logs/#{data_id}?section=log2&date=#{selection}", type: "get", dataType: "script"
          $(this).show()
          $(this).find('.drilling-log-entry').each ->
            $(this).show()
        else
          $(this).hide()
    return false

  $('#add_new_entry_jump').live "click", ->
    $("html, body").animate({ scrollTop: $(document).height() }, "fast")
    return false

  if $('#checkbox_override_date').is(':checked')
    $('.date-fields').removeClass 'hidden'

  $('.toggle-content-link').live "click", ->

    content = $(this).next('.toggle-content')
    if content.length > 0
      if content.hasClass 'hidden'
        content.removeClass 'hidden'
      else
        content.addClass 'hidden'
    return false


  $('.sub-tray-link').live "click", ->
    $('.sub-tray-link').each ->
      li = $(this).closest('li')
      if li.hasClass 'active'
        li.removeClass 'active'
        $(this).addClass 'blue-text'

    $(this).closest('li').addClass 'active'
    $(this).removeClass 'blue-text'

    $('.sub-tray').addClass 'hidden'
    $('.sub-tray[data-tray=' + $(this).attr('data-tray') + ']').removeClass 'hidden'

    return false