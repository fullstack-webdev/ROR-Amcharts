$ ->
  if navigator.userAgent.match(/iPad;.*CPU.*OS 7_\d/i)
   $('html').addClass('ipad ios7')

#  content = document.getElementsByClassName('remote-tray')
#  content.addEventListener 'touchstart', (event) ->
#    @allowUp = @scrollTop > 0
#    @allowDown = @scrollTop < @scrollHeight - (@clientHeight)
#    @slideBeginY = event.pageY
#    return
#  content.addEventListener 'touchmove', (event) ->
#    up = event.pageY > @slideBeginY
#    down = event.pageY < @slideBeginY
#    @slideBeginY = event.pageY
#    if up and @allowUp or down and @allowDown
#      event.stopPropagation()
#    else
#      event.preventDefault()
#    return

#  document.ontouchmove = (event) ->
#    event.preventDefault()

#  xStart = yStart = 0;
#  document.addEventListener 'touchstart' , (e) ->
#    xStart = e.touches[0].screenX
#    yStart = e.touches[0].screenY
#  document.addEventListener 'touchmove', (e) ->
#    xMovement = Math.abs(e.touches[0].screenX - xStart)
#    yMovement = Math.abs(e.touches[0].screenY - yStart)
#    if (yMovement * 3) > xMovement
#      e.preventDefault()

  bouncefix.add('drill-view-chart');
  bouncefix.add('drill-view-port');

  close_signin = () ->
    $('.m-login-section').hide()
    $('#close-signin').hide()
    $('.m-signin-button').show()

  open_signin = () ->
    $('.m-login-section').slideDown()
    $('.m-signin-button').hide()
    $('#close-signin').show()

  close_nav = () ->
    $('#nav-icon').removeClass('closed')
    $('.navmenu').hide()

  open_nav = () ->
    $('#nav-icon').addClass('closed')
    $('.navmenu').slideDown()

  $('#nav-icon').live 'click', () ->
    if $(this).hasClass('closed')
      close_nav()
      $('.main').show()
      $('.page-title').show()
    else
      close_signin()
      open_nav()
      $('.main').hide()
      $('.page-title').hide()

  $('.m-signin-button').live 'click', () ->
    close_nav()
    open_signin()
    $('.main').hide()
    $('.page-title').hide()
  #    $('#session_email').trigger('focus')

  $('#close-signin').on 'click', () ->
    close_signin()
    $('.main').show()
    $('.page-title').show()

  $.stayInWebApp()