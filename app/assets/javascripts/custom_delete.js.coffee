
$.rails.allowAction = (element) ->
  # The message is something like "Are you sure?"
  message = element.data('confirm')
  # If there's no message, there's no data-confirm attribute,
  # which means there's nothing to confirm
  return true unless message
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  $link = element.clone()
  # We don't necessarily want the same styling as the original link/button.
    .removeAttr('class')
  # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm')
  # We want a button
    .addClass('btn').addClass('btn-primary').addClass('red').addClass('align-top').addClass('white-text').addClass('pull-right')
  # We want it to sound confirmy
    .html("Delete")

  # Create the modal box with the message
  modal_html = """
                 <div class="modal" id="myModal" style="z-index: 10000000000;">
                   <div class="modal-header">
                     <a class="delete-button-small pull-right" data-dismiss="modal">×</a>
                     <h2 class="page-title" style="color: #676767; font-size: 20px;">#{message}</h2>
                   </div>
                   <div class="modal-footer">
                     <a data-dismiss="modal" class="btn btn-default pull-right align-top" style="margin-right: 10px; margin-top: 3px;">Cancel</a>
                   </div>
                 </div>
                 """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').prepend($link)
  # Pop it up
  $modal_html.modal()
  $('.modal-backdrop').css('z-index', '10000000000')

  $link.click ->
    $modal_html.find('.delete-button-small').trigger 'click'

  # Prevent the original link from working
  return false