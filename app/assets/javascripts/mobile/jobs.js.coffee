$ ->
  $('.remote-tray-toggle').on "click", (event) ->
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
            child_tray.find('.tray-content').show()
            child_tray.find('.remote-loading').addClass 'hidden'
            child_tray.find('.loading').addClass 'hidden'
          else
            child_tray.find('.tray-content').hide()
            child_tray.find('.remote-loading').removeClass 'hidden'
            child_tray.find('.loading').removeClass 'hidden'
            if child_id > 0
              $.ajax('/' + child_controller + '/' + child_id + "?section=" + child_tray_name,
                type: 'get'
                dataType: 'script'
              ).done ->
                $('.remote-tray').addClass 'custom-data-closed'
                $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
                $(".remote-tray[data-tray=" + child_tray_name + "]").removeClass 'custom-data-closed'
            else
              $.ajax('/' + child_controller + "?section=" + child_tray_name,
                type: 'get'
                dataType: 'script'
              ).done ->
                $('.remote-tray').addClass 'custom-data-closed'
                $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
                $(".remote-tray[data-tray=" + child_tray_name + "]").removeClass 'custom-data-closed'

      if main_tray.find('.tray-content').hasClass 'content-loaded'
        main_tray.find('.tray-content').show()
        main_tray.find('.remote-loading').addClass 'hidden'
        main_tray.find('.loading').addClass 'hidden'
        loadChildTray()
      else
        main_tray.find('.tray-content').hide()
        main_tray.find('.remote-loading').removeClass 'hidden'
        main_tray.find('.loading').removeClass 'hidden'
        if main_id > 0
          $.ajax('/' + main_controller + '/' + main_id + "?section=" + main_tray_name,
            type: 'get'
            dataType: 'script'
          ).done ->
            $('.remote-tray').addClass 'custom-data-closed'
            $(".remote-tray[data-tray=" + main_tray_name + "]").removeClass 'custom-data-closed'
            loadChildTray()
        else
          $.ajax('/' + main_controller + "?section=" + main_tray_name,
            type: 'get'
            dataType: 'script'
          ).done ->
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
