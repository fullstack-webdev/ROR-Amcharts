# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#company_filter').live "change", ->
    company_id = $(this).find('option:selected').val()
    if company_id == $('#current_company').html() || company_id == ''
      return false

    if company_id == '0' # create new company
      window.location = '/companies/new'
    else
      window.location = '/admin/company/'+company_id
    return false