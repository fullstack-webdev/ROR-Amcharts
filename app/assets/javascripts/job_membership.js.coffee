$ ->

  $('.add-member-loading-button').live "click", ->
    $('.member-loading').removeClass 'hidden'
    $('#new_member_form').hide()

  $('#add_job_member').live "click", ->
    $('#new_member_name').val('')
    $('#new_member_id').val('')
    $('#add_job_member').hide()
    $('#new_member_form').show()
    $('#new_member_name').focus()
    return false

  $('#cancel_add_member').live "click", ->
    $('#new_member_form').addClass 'hidden'
    $('#add_job_member').show()
    $('#new_member_form').hide()
    return false

  $('#toggle_member_names').live "click", ->
    if $(this).attr('data-toggle') == "open"
      $(this).attr('data-toggle', 'closed')
      $('.member-full-list').addClass 'hidden'
      $('#toggle_member_show').removeClass 'hidden'
      $('#toggle_member_hide').addClass 'hidden'
    else
      $(this).attr('data-toggle', 'open')
      $('.member-full-list').removeClass 'hidden'
      $('#toggle_member_show').addClass 'hidden'
      $('#toggle_member_hide').removeClass 'hidden'
      if $('#team_list').attr('data-loaded') == 'false'
        job_id = $('#team_list').attr('data-job')
        $.ajax({
          url: "/jobs/#{job_id}?section=team_list",
          type: "GET",
          dataType: "script"
        });

    return false

  $('#close_members').live "click", ->
    $('#toggle_member_names').attr('data-toggle', 'closed')
    $('.member-full-list').addClass 'hidden'
    $('#toggle_member_show').removeClass 'hidden'
    $('#toggle_member_hide').addClass 'hidden'
    return false



  $('.job-membership-type').live "click", ->
    $('.job-membership-type').each ->
      li = $(this).closest('li')
      if li.hasClass 'active'
        li.removeClass 'active'
        $(this).addClass 'blue-text'

    $(this).closest('li').addClass 'active'
    $(this).removeClass 'blue-text'

    if $(this).attr('data-type') == "elephant"
      $('#elephant_user').removeClass 'hidden'
      $('#external_user').addClass 'hidden'
    else
      $('#elephant_user').addClass 'hidden'
      $('#external_user').removeClass 'hidden'

    return false