(() ->
  log = (message) ->
    $('<div>').text(message).prependTo '#log'
    $('#log').scrollTop 0
    return

  split = (val) ->
    val.split /,\s*/

  extractLast = (term) ->
    split(term).pop()

  $.widget 'custom.autocompletecombo',
    options:
      defaultValue: ''
      placeholder: ''
      title: ''
      style: 'padding-right: 20px; width: 215px;'
      class: 'job-field-value-editable single-custom-combobox-input'
      multiple: false

    _create: ->
      @wrapper = $('<span>').addClass('single-custom-combobox').insertAfter(@element)
      @element.hide()
      @_createAutocomplete()
      @_createShowAllButton()
      return

    _createAutocomplete: ->
      self = @
      selected = @element.children(':selected')
      value = if selected.val() then selected.text() else ''
      @input = $('<input>').appendTo(@wrapper)
      .val(@options.defaultValue)
      .attr('title', @options.title)
      .attr('placeholder', @options.placeholder)
      .attr('style', @options.style)
      .addClass(@options.class).autocomplete(
        delay: 0
        minLength: 0
        source: $.proxy(this, '_source')
        focus: ->
          self._trigger("focus", null, {})
          false
        select: (event, ui) ->
          this.value = ui.item.label;
          self._trigger("select", null, ui)
          false
      ).tooltip(tooltipClass: 'ui-state-highlight')
      @_on @input, autocompletechange: '_removeIfInvalid'
      return

    _createShowAllButton: ->
      input = @input
      wasOpen = false
      $('<a>').attr('tabIndex', -1)
      .attr('title', 'Show All Items')
      .tooltip()
      .appendTo(@wrapper)
      .button(
        icons:
          primary: 'ui-icon-triangle-1-s'
        text: false
      ).removeClass('ui-corner-all')
      .addClass('single-custom-combobox-toggle ui-corner-right')
      .mousedown(()->
        wasOpen = input.autocomplete('widget').is(':visible')
        return
      ).click(()->
        input.focus()
        if wasOpen
          return
        input.autocomplete 'search', ''
      )

    _source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(extractLast(request.term)), 'i')
      response @element.children('option').map(->
        text = $(this).text()
        if @value and (!extractLast(request.term) or matcher.test(text))
          return {
          label: text
          value: @value
          option: this
          }
        return
      )
      return

    _removeIfInvalid: (event, ui) ->
      if ui.item
        return
      data = if @options.multiple then @_getMultiValue() else {}
      value = data.value || ''
      @input.val value
      @element.val value
      @_trigger("remove", null, data)
      return

    _destroy: ->
      @wrapper.remove()
      @element.show()
      return

    _getMultiValue: () ->
      terms = split(@input.val())
      ids = []
      newTerms = []
      terms.pop()
      that = this
      terms.forEach (value) ->
        valid = false
        id = undefined
        that.element.children('option').each ->
          if $(this).text() == value
            @selected = valid = true
            id = $(this).val()
          return
        if valid
          newTerms.push value
          ids.push id
        return
      newTerms.push ''
      value = newTerms.join(', ')
      {
      ids: ids,
      value: value
      }
  return)()