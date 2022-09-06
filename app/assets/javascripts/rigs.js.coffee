$ ->

  $('#new_rig_link').live "click", ->
    $('#modal_popup').find(".modal-content").children().remove()
    return false
  $('.rig-update-field').live "change", ->
    console.log($(this).attr("data-field"));
    if $(this).val().length > 0
      $.ajax '/rigs/' + $(this).attr("data-id"),
        data: {"update_field": "true", "field": $(this).attr("data-field"), "value": $(this).val()},
        type: 'put',
        dataType: 'script'