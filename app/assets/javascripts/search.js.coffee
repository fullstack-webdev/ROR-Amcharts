$ ->

  $('.search-units').customSelect()

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('.add-search-field').click ->
    $('.search-field').each (index, element) =>
      if $(element).css("display") == "none"
        $(element).show()
        return false
    return false



  $('.client-name').each (index, element) =>
    $(element).autocomplete
      source: $(element).data('autocomplete-source')
      focus: focusevent
      select: (event, ui) ->
        $(this).closest('.search-field').find("input[id=client_id]").val(ui.item.id)

  $('.district-name').each (index, element) =>
    $(element).autocomplete
      source: $(element).data('autocomplete-source')
      focus: focusevent
      select: (event, ui) ->
        $(this).closest('.search-field').find("input[id=district_id]").val(ui.item.id)


  $('.search-constraint-data-type').live "change", ->

    $(this).closest('.search-field').find('.search-constraint-second').hide();
    $(this).closest('.search-field').find('.search-job-type').hide();

    if $(this).val() == '2'
      $(this).closest('.search-field').find('.loading').removeClass 'hidden'
    else
      $(this).closest('.search-field').find('.loading').addClass 'hidden'

    if $(this).val() == '5'
      $(this).closest('.search-field').find('.loading').removeClass 'hidden'
    else
      $(this).closest('.search-field').find('.loading').addClass 'hidden'

    if $(this).val() == '6'
      $(this).closest('.search-field').find('.loading').removeClass 'hidden'
    else
      $(this).closest('.search-field').find('.loading').addClass 'hidden'

    if $(this).val() == '3'
      $(this).closest('.search-field').find('.client-name').show().prev().show()
    else
      $(this).closest('.search-field').find('.client-name').hide().prev().hide()

    if $(this).val() == '4'
      $(this).closest('.search-field').find('.district-name').show().prev().show()
    else
      $(this).closest('.search-field').find('.district-name').hide().prev().hide()

    if $(this).val() == '2' || $(this).val() == '1' || $(this).val() == '5' || $(this).val() == '6'
      $.ajax '/search?data_type=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-division-select').live "change", ->
    $.ajax '/search?data_type=' + $(this).closest('.search-field').find('.search-constraint-data-type').val() + '&division=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-segment-select').live "change", ->
    $.ajax '/search?data_type=' + $(this).closest('.search-field').find('.search-constraint-data-type').val() + '&segment=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-product-line-select').live "change", ->
    $.ajax '/search?data_type=' + $(this).closest('.search-field').find('.search-constraint-data-type').val() + '&product_line=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-job-template-select').live "change", ->
    $.ajax '/search?data_type=' + $(this).closest('.search-field').find('.search-constraint-data-type').val() + '&job_template=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-field-select').live "change", ->
    job_id = $(this).closest('.search-field').find('[id=job_job_template_id]').val()
    $.ajax '/search?data_type=' + $(this).closest('.search-field').find('.search-constraint-data-type').val() + '&field=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id") + "&job_template=" + job_id, dataType: 'script'

  $('.submit-form').live "click", ->
    $(this).closest('form').submit()