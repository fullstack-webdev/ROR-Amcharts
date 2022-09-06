$ ->

  $('.new-bha').live "click", ->
    $('.bha-content').addClass 'hidden'
    $('#bha_loader').removeClass 'hidden'
    $('.bha-button').each (index, element) ->
      $(element).addClass 'gray'
    return false

  $('.cancel-bha').live "click", ->
    $('.bha-button').first().trigger('click')
    $('body').animate({scrollTop : 0 }, 'fast')
    return false

  $('.bha-button').live "click", ->
    $('.bha-button').each (index, element) ->
      $(element).addClass 'gray'
    $(this).removeClass 'gray'
    return false

  $('.bha-show-fields').live "click", ->
    parent = $(this).closest('.bha-tool')
    if $(this).is(':checked')
      parent.find('.bha-other-items').removeClass "hidden"
      #parent.find('.order-button').removeClass "hidden"
    else
      parent.find('.bha-other-items').addClass "hidden"
      #parent.find('.order-button').addClass "hidden"

  $('.bha-order-up').live "click", ->
    tool = $(this).closest('.bha-tool')
    prev = tool.prev()
    if prev.hasClass 'bha-tool'
      prev.before(tool)
      tool.addClass 'document-reorder-background'
      setTimeout (->
        tool.removeClass "document-reorder-background"
      ), 1000
    return false

  $('.bha-remove').live "click", ->
    $(this).closest('.bha-tool').remove()
    return false

  $('#add_new_bha_item').live "click", ->
    $('#add_tool').addClass 'hidden'
    $('#add_tool_loader').removeClass 'hidden'
    params = 'tool=' + $('#bha_tool_options').val() + '&job=' + $(this).attr("data-job")
    $.ajax '/bhas/new?' + params, type: 'get', dataType: 'script'
    return false

  $('.select-tool-type').live "change", ->
    if $(this).find('option:selected').val() == '1'
      $(this).next('.bit-info').removeClass 'hidden'
    else
      $(this).next('.bit-info').addClass 'hidden'


  $('.tab').live "click", ->
    $('.tab-content').addClass 'hidden'
    tabcontent = $(".tab-content[data-tabsection=" + $(this).attr('data-tabsection')  + "]")
    tabcontent.removeClass 'hidden'
    return false
