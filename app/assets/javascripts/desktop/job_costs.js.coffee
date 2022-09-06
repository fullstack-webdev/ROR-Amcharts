$ ->

  $('#toggle_cost').live "click", ->
    if $(this).attr('data-toggle') == "open"
      $(this).attr('data-toggle', 'closed')
      $('.full-costs').addClass 'hidden'
      $('#toggle_cost_show').removeClass 'hidden'
      $('#toggle_cost_hide').addClass 'hidden'
    else
      $(this).attr('data-toggle', 'open')
      $('.full-costs').removeClass 'hidden'
      $('#toggle_cost_show').addClass 'hidden'
      $('#toggle_cost_hide').removeClass 'hidden'
      if $('#full_cost').attr('data-loaded') == 'false'
        job_id = $('#full_cost').attr('data-job')
        $.ajax({
          url: "/jobs/#{job_id}?section=full_cost",
          type: "GET",
          dataType: "script"
        });

    return false

  $('#close_cost').live "click", ->
    $('#toggle_cost').attr('data-toggle', 'closed')
    $('.full-costs').addClass 'hidden'
    $('#toggle_cost_show').removeClass 'hidden'
    $('#toggle_cost_hide').addClass 'hidden'
    return false