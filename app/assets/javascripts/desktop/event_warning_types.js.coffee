# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  if $('#infinite-scrolling').size() > 0
    $(window).on 'scroll', ->
      more_posts_url = $('.pagination .next_page a').attr('href')
      if more_posts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60
        console.log 'infinite loading...'
        $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
        $.getScript more_posts_url
      return
