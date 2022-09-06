$ ->
  $('.custom-select').customSelect()

  #if (!window.matchMedia || !window.matchMedia("(max-device-width: 1024px)").matches)
  #$('.job-type-description-target').tooltip()
  #$('.tooltip-info').tooltip()
  #$('.unit-tooltip').tooltip()

  $('.unitsSelect').customSelect()

  #  $('.date-picker').datepicker()


  $('#close_job a').live "click", ->
    $('#close_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('Complete')
    return false

  $('#begin_on_job a').live "click", ->
    $('#begin_on_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('On Job')
    return false

  $('#begin_post_job a').live "click", ->
    $('#begin_post_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('Post Job')
    return false

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#new_member_name').autocomplete
    source: $('#new_member_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#new_member_name").val(ui.item.label)
      $("#new_member_id").val(ui.item.id)
  #$("#new_member_form").submit()

  $('#new_note_name').autocomplete
    source: $('#new_note_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#new_note_name").val(ui.item.label)
        $("#new_note_name_id").val(ui.item.id)

  $('.job-member-list-item').live "mouseenter", ->
    $(this).find('.job-member-edit-button').css('visibility', 'visible')
    $(this).find('.delete-button-small').css('visibility', 'visible')

  $('.job-member-list-item').live "mouseleave", ->
    $(this).find('.job-member-edit-button').css('visibility', 'hidden')
    $(this).find('.delete-button-small').css('visibility', 'hidden')

  $('.custom-data-input').click ->
    $(this).select()

  $('.custom-data-input').keyup ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()

  $('.custom-data-input').change ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_",
      "") + '?value=' + $(this).val() + "&job=" + $(this).attr('data-job') + "&name=" + $(this).attr('data-name'), type: 'put', dataType: 'script'

  $('.unitsSelect').change ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_unit_",
      "") + '?unit=' + $(this).val(), type: 'put', dataType: 'script'


  $('.job-tray-toggle').click (event) ->
    $('.job-tray-toggle').closest('li').removeClass 'active'
    $('.job-tray').addClass 'custom-data-closed'
    $(this).closest('li').addClass 'active'
    tray = $(this).attr('data-tray')
    $(".job-tray[data-tray=" + tray + "]").removeClass 'custom-data-closed'
    #document.location.hash = tray;
    if window.history && window.history.pushState
      history.replaceState({}, "", '#' + tray)

    #if $('.job-main-div').length > 0
    #  $('body').animate({scrollTop : $('.job-main-div').position().top - 70 }, 'fast')
    event.preventDefault()

  $('.job-tray-toggle').click (event) ->
    if $(this).attr('data-tray') == "activity"
      $('#activity_list').hide()
      $('.activity-loading').removeClass 'hidden'
      $('.activity-loading').find('.loading').removeClass 'hidden'
      if $('.job-main-div').length > 0
        $.ajax '/activities?job_id=' + $('.job-main-div').attr("id").replace("job_",
          ""), type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "job_failures"
      $('.failures_loading').removeClass 'hidden'
      $('.failures_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=job_failures", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "cost"
      $('.cost_loading').removeClass 'hidden'
      $('.cost_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=cost", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "reports"
      $('.reports_loading').removeClass 'hidden'
      $('.reports_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=reports", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "notes"
      $('.notes-loading').removeClass 'hidden'
      $('.notes-loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=notes", type: 'get', dataType: 'script'

    if $(this).attr('data-tray') == "my_jobs"
      $.ajax '/jobs/?section=my_jobs', type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "pre_job"
      $.ajax '/jobs/?section=pre_job', type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "post_job"
      $.ajax '/jobs/?section=post_job', type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "in_progress"
      $.ajax '/jobs/?section=in_progress', type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "complete"
      $.ajax '/jobs/?section=complete', type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "documents_data"
      $('.documents_loading').removeClass 'hidden'
      $('.documents_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=documents_data", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "tools_assets"
      $('.assets_loading').removeClass 'hidden'
      $('.assets_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_",
        "") + "?section=tools_assets", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "failures"
      if $('#overview_failures').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=failures", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "insight"
      if $('#overview_insight').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=insight", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "company"
      if $('#overview_company').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=company", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "drilling"
      if $('#overview_drilling').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=drilling", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "jobs"
      if $('#overview_jobs').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=jobs", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "overview_npt"
      if $('#overview_npt').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=overview_npt", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "rigs"
      if $('#overview_rigs').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=rigs", type: 'get', dataType: 'script'

    if $(this).attr('data-tray') == "asset_activity"
      $('#asset_activity_loading').removeClass 'hidden'
      $('#asset_activity_loading').find('.loading').removeClass 'hidden'
      $.ajax '/parts/' + $(this).attr('data-id') + "?section=asset_activity", type: 'get', dataType: 'script'
    event.preventDefault()


  $('.show-tray').live "click", (event) ->
    tray = $(this).attr('data-tray')
    $(".remote-tray-toggle[data-tray=" + tray + "]").click()
    event.preventDefault()


  $('.remote-tray-toggle').live "click", (event) ->
    main_tray_name = $(this).attr('data-tray')
    main_controller = $(this).attr('data-tray-controller')
    main_id = $(this).attr('data-id')
    if typeof(main_id) == "undefined" || main_id == null
      main_id = 0

    child_tray_name = ''
    child_controller = ''
    child_id = 0

    child_name = $(this).attr('data-tray-child')
    parent_name = $(this).attr('data-tray-parent')
    if typeof(child_name) == "undefined"
      child_name = null
    if typeof(parent_name) == "undefined"
      parent_name = null

    $('.remote-tray').addClass 'custom-data-closed'

    parent_tray_nav = $('.parent-tray-nav')
    parent_tray_nav.find('.remote-tray-toggle').closest('li').removeClass 'active'

    if child_name != null
      child_tray_nav = $('.child-tray-nav')
      child_tray_nav.find('.remote-tray-toggle').closest('li').removeClass 'active'
      child_tray_name = $(this).attr('data-tray-child')
      child_controller = main_controller
      child_id = main_id

    if parent_name != null
      child_tray_nav = $('.child-tray-nav')
      child_tray_nav.find('.remote-tray-toggle').closest('li').removeClass 'active'
      child_tray_name = main_tray_name
      child_controller = main_controller
      child_id = main_id
      parent_tray_nav_item = $(".remote-tray-toggle[data-tray=" + parent_name + "]")
      parent_tray_nav_item.attr('data-tray-child', $(this).attr('data-tray'))
      parent_tray_nav_item.closest('li').addClass 'active'
      main_tray_name = parent_tray_nav_item.attr('data-tray')
      main_controller = parent_tray_nav_item.attr('data-tray-controller')
      main_id = parent_tray_nav_item.attr('data-id')
      if main_id == null
        main_id = 0

    #    $(this).closest('li').addClass 'active'

    #    $(".tray-content").not(".content-loaded").html('')
    $(".tray-content").not(".content-loaded").closest('.remote-tray').find('tray-content').remove()
    $(".remote-tray-toggle[data-tray=" + main_tray_name + "]").closest('li').addClass 'active'

    if main_tray_name.length > 0 && main_controller.length > 0
      # Show Main Tray
      main_tray = $(".remote-tray[data-tray=" + main_tray_name + "]")
      main_tray.removeClass 'custom-data-closed'

      if window.history && window.history.pushState
        if child_tray_name != null && child_tray_name != ''
          history.replaceState({}, "", '#' + child_tray_name)
        else
          history.replaceState({}, "", '#' + main_tray_name)

      loadChildTray = () ->
        # Load Child, if there is one
        if child_tray_name != null && child_tray_name != ''
          child_tray = $(".remote-tray[data-tray=" + child_tray_name + "]")
          child_tray.removeClass 'custom-data-closed'
          $('.remote-tray-toggle[data-tray=' + child_tray_name + ']').closest('li').addClass 'active'
          if child_tray.find('.tray-content').hasClass 'content-loaded'
            window.auid++
            child_tray.find('.tray-content').show()
            child_tray.find('.remote-loading').addClass 'hidden'
            child_tray.find('.loading').addClass 'hidden'
          else
            child_tray.find('.tray-content').hide()
            child_tray.find('.remote-loading').removeClass 'hidden'
            child_tray.find('.loading').removeClass 'hidden'
            if child_id > 0
              window.auid++
              $.ajax('/' + child_controller + '/' + child_id + "?section=" + child_tray_name + "&auid=" + window.auid,
                type: 'get'
                dataType: 'script'
              ).done ->
                if window.cb_auid == window.auid
                  $('.remote-tray').addClass 'custom-data-closed'
                  $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
                  $(".remote-tray[data-tray=" + child_tray_name + "]").removeClass 'custom-data-closed'
            else
              window.auid++
              $.ajax('/' + child_controller + "?section=" + child_tray_name + "&auid=" + window.auid,
                type: 'get'
                dataType: 'script'
              ).done ->
                if window.cb_auid == window.auid
                  $('.remote-tray').addClass 'custom-data-closed'
                  $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
                  $(".remote-tray[data-tray=" + child_tray_name + "]").removeClass 'custom-data-closed'

      if main_tray.find('.tray-content').hasClass 'content-loaded'
        window.auid++
        main_tray.find('.tray-content').show()
        main_tray.find('.remote-loading').addClass 'hidden'
        main_tray.find('.loading').addClass 'hidden'
        loadChildTray()
      else
        main_tray.find('.tray-content').hide()
        main_tray.find('.remote-loading').removeClass 'hidden'
        main_tray.find('.loading').removeClass 'hidden'
        if main_id > 0
          window.auid++
          $.ajax('/' + main_controller + '/' + main_id + "?section=" + main_tray_name + "&auid=" + window.auid,
            type: 'get'
            dataType: 'script'
          ).done ->
            if window.cb_auid == window.auid
              $('.remote-tray').addClass 'custom-data-closed'
              $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
              loadChildTray()
        else
          window.auid++
          $.ajax('/' + main_controller + "?section=" + main_tray_name + "&auid=" + window.auid,
            type: 'get'
            dataType: 'script'
          ).done ->
            if window.cb_auid == window.auid
              $('.remote-tray').addClass 'custom-data-closed'
              $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
              loadChildTray()

      # Update main container width on system page
      if main_tray_name == 'rig_overview'
        jQuery("#main_container").css "width", "100%"
      else
        jQuery("#main_container").css "width", "75%"

    event.preventDefault()


  if document.location.hash != ''
    tray_name = document.location.hash.replace('#', '')
    if $(".job-tray-toggle[data-tray=" + tray_name + "]").length != 0
      $(".job-tray-toggle[data-tray=" + tray_name + "]").trigger "click"
    else if $(".remote-tray-toggle[data-tray=" + tray_name + "]").length != 0
      tray_nav_item = $(".remote-tray-toggle[data-tray=" + tray_name + "]")
      parent_name = tray_nav_item.attr('data-tray-parent')
      if typeof(parent_name) == "undefined"
        parent_name = null
      if parent_name != null
        child_tray_nav = $('.child-tray-nav')
        child_tray_nav.find('.remote-tray-toggle').closest('li').removeClass 'active'
        tray_nav_item.closest('li').addClass 'active'
        parent_item = $(".remote-tray-toggle[data-tray=" + parent_name + "]")
        parent_item.attr('data-tray-child', tray_name)
        parent_item.trigger "click"
      else
        $(".remote-tray-toggle[data-tray=" + tray_name + "]").trigger "click"


  #$('#add_failure').click ->
  #  $('#modal_popup').css('visibility', 'visible')
  #  $('#modal_popup').find('.modal-popup').css('margin-top', $('body').scrollTop() + 100)
  #  $('#modal_popup').height($(document).height() + 100)
  #  $('#modal_popup').find('.loading').removeClass 'hidden'


  $('.division-jobs-toggle').click ->
    $('.division-job-item').each ->
      if $(this).hasClass 'hidden'
        $(this).removeClass 'hidden'
      else
        $(this).addClass 'hidden'
    return false

  #if $('#job_activities')
  #  $.ajax '/activities' + '?job_id=' + $(this).val(), type: 'put', dataType: 'script'

  $('.expand-job-description').live "click", ->
    $(this).remove()
    $('.job-description-custom-data-div').css("max-height", 100000)
    return false


  $('.change-asset-type').live "click", ->
    $('.change-asset-type').each ->
      li = $(this).closest('li')
      if li.hasClass 'active'
        li.removeClass 'active'
        $(this).addClass 'blue-text'

    $(this).closest('li').addClass 'active'
    $(this).removeClass 'blue-text'

    $('.asset-type-form').each ->
      $(this).addClass 'hidden'

    $('.asset-type-form[data-type=' + $(this).attr('data-type') + ']').removeClass 'hidden'
    $('#part_type').val($(this).attr('data-type'))

    return false


  $('#complete_job').live "click", ->
    $.ajax '/jobs/' + $(this).attr('data-id') + "?section=rating", type: 'get', dataType: 'script'
    return true


  $('.job-update-field').live "change", ->
    if $(this).val().length > 0
      $.ajax '/jobs/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).val(), type: 'put', dataType: 'script'

  $('#confirm-assets').live "click", ->
    div = $(this).closest('div')
    div.addClass 'hidden'
    div.next('div').removeClass 'hidden'
    return false
  $('#confirm-assets-undo').live "click", ->
    div = $(this).closest('div')
    div.addClass 'hidden'
    div.prev('div').removeClass 'hidden'
    return false

  $('#jobs_filter').live "change", ->
    value = $(this).find('option:selected').val()
    $('.job-link').each ->
      $(this).show()
    if value == '1'
      $('.job-link').each ->
        if $(this).attr('data-member') == 'false'
          $(this).hide()
    if value == '2'
      $('.job-link').each ->
        if $(this).attr('data-status') != '5'
          $(this).hide()
    if value == '3'
      $('.job-link').each ->
        if $(this).attr('data-status') != '6'
          $(this).hide()
    if value == '4'
      $('.job-link').each ->
        if $(this).attr('data-status') != '7'
          $(this).hide()


  $('.loading-jobs').live 'click', (event)  ->
    $('#jobs').addClass 'hidden'
    $('#jobs_loading').removeClass 'hidden'
    $('#jobs_loading').find('.loading').removeClass 'hidden'
    event.preventDefault()

$ ->
  # Set default configuration toggle
  $('#set_default_conf').on 'click', (event) ->
    event.preventDefault()
    $('#set_default_conf_popup').css('visibility', 'visible');

  # Set default configuration toggle
  $('#close_default_conf_popup').on 'click', (event) ->
    event.preventDefault()
    $('#set_default_conf_popup').css('visibility', 'hidden');

  # Warning detail link
  $('.warning-detail-btn').live 'click', (event) ->
    event.preventDefault()
    $.ajax '/event_warnings/' + $(this).attr("data-id") + '/get_warning_detail', type: 'get', dataType: 'script'

  $('#close_warning_detail_popup').live 'click', (event) ->
    event.preventDefault()
    $('#warning_detail_popup').css('visibility', 'hidden');

  $('#close_config_detail_popup').live 'click', (event) ->
    event.preventDefault()
    $('#config_detail_popup').empty();
    $('#config_detail_popup').css('visibility', 'hidden');

  $('.wells-overview-toggle div').live 'click', ->
    value = $(this).data('view-mode')
    $('.wells-overview-toggle div').removeClass 'active'
    $(this).addClass 'active'
    $('#overview_jobs .wells-overview').hide()
    $('#overview_jobs .wells-overview.overview-' + value).show()
    return false

  $('#close_modal').live "click", ->
    if $('#map').length > 0
      $('#map').show()
    $('#modal_popup').css "visibility", "hidden"
    $('#modal_popup').find(".modal-content").children().remove()
    $('#modal_popup').height(0)
    return false

  $('.well-update-field').live "change", ->
    if $(this).val().length > 0
      $.ajax '/wells/' + $(this).attr("data-id"),
        data: {"update_field": "true", "field": $(this).attr("data-field"), "value": $(this).val()},
        type: 'put',
        dataType: 'script'