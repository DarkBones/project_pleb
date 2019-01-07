# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('.pagination').hide()
  if $('.pagination').length
    $(window).scroll ->
      $('.pagination').hide()
      url = $('.pagination .next_page').attr('href')
      if url
        url = window.location.pathname + "?" + url.split("?")[1]
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("")
        $.getScript(url)
    $(window).scroll()