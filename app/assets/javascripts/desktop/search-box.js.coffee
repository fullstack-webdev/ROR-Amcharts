$ ->

  # handling the focus event on search box
  $('.global-search').live 'focus', ->
    $(this).animate({
      width: '100%'
    }, 400)

  # handling the blur event on input2
  $('.global-search').live 'blur', ->
    if($(this).val() == '')
      $(this).animate({
        width: '0'
      }, 400)


