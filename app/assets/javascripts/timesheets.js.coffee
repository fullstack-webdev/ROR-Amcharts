class Timesheet
  @recount: ->
    total_scheduled = 0
    total_worked = 0

    $('.user-timesheet').each (root_index, timesheet) =>
      user_scheduled = parseFloat($(timesheet).find('.user-total-time-scheduled').attr('data-hours'))
      user_worked = parseFloat($(timesheet).find('.user-total-time').attr('data-hours'))
      total_scheduled += user_scheduled
      total_worked += user_worked

    $('.total-scheduled').text(total_scheduled)
    $('.total-worked').text(total_worked)

$ ->

  $('.day-button-schedule').live "click", ->
    job = $(this).attr('data-job')
    user = $(this).attr('data-user')
    date = $(this).attr('data-day')
    if $(this).attr("data-type") == "none"
      $(this).attr("data-type", "scheduled")
      $(this).removeClass "gray"
      $(this).addClass "light-blue"
      $(this).attr('data-type', 'scheduled')
      user_scheduled = $(this).closest('.user-timesheet').find('.user-total-time-scheduled')
      user_scheduled.attr('data-hours', parseFloat(user_scheduled.attr('data-hours')) + parseFloat($(this).val()))
      Timesheet.recount()

    else if $(this).attr("data-type") == "scheduled"
      $(this).attr("data-type", "worked")
      $(this).removeClass "light-blue"
      $(this).addClass "green"
      $(this).popover('show')
    else
      $(this).attr("data-type", "none")
      $(this).removeClass "green"
      $(this).addClass "gray"
      $(this).attr('data-type', 'none')
      $('.day-button').popover('hide')
      user_scheduled = $(this).closest('.user-timesheet').find('.user-total-time-scheduled')
      user_scheduled.attr('data-hours', parseFloat(user_scheduled.attr('data-hours')) - parseFloat($(this).val()))
      user_worked = $(this).closest('.user-timesheet').find('.user-total-time')
      user_worked.attr('data-hours', parseFloat(user_worked.attr('data-hours')) - parseFloat($(this).val()))
      user_worked.text(user_worked.attr('data-hours'))
      Timesheet.recount()


    return false


  $('.time-close-button').live "click", ->
    popup = $(this).closest('.timesheet')
    main_button = $('.day-button[data-user=' + popup.attr('data-user') + '][data-day=' + popup.attr('data-day') + '][data-job=' + popup.attr('data-job') + ']')
    job = main_button.attr('data-job')
    user = main_button.attr('data-user')
    date = main_button.attr('data-day')

    user_worked = main_button.closest('.user-timesheet').find('.user-total-time')
    user_worked.attr('data-hours', parseFloat(user_worked.attr('data-hours')) + parseFloat(main_button.val()))
    user_worked.text(user_worked.attr('data-hours'))
    Timesheet.recount()
    $('.day-button').popover('hide')


    return false

  $('.time-decrease-button').live "click", ->
    unit = parseFloat($(this).attr('data-unit'))
    new_value = parseFloat($('.time-confirm-button').val()) - unit
    if new_value >= 0
      $('.time-confirm-button').val(new_value)
    return false

  $('.time-increase-button').live "click", ->
    unit = parseFloat($(this).attr('data-unit'))
    $('.time-confirm-button').val(parseFloat($('.time-confirm-button').val()) + unit)
    return false

  $('.time-confirm-button').live "click", ->
    popup = $(this).closest('.timesheet')
    main_button = $('.day-button[data-user=' + popup.attr('data-user') + '][data-day=' + popup.attr('data-day') + '][data-job=' + popup.attr('data-job') + ']')
    job = main_button.attr('data-job')
    user = main_button.attr('data-user')
    date = main_button.attr('data-day')
    main_button.val($(this).val())
    main_button.attr('data-type', 'worked')

    user_worked = main_button.closest('.user-timesheet').find('.user-total-time')
    user_worked.attr('data-hours', parseFloat(user_worked.attr('data-hours')) + parseFloat(main_button.val()))
    user_worked.text(user_worked.attr('data-hours'))
    Timesheet.recount()

    $('.day-button').popover('hide')


    return false



  Timesheet.recount()

