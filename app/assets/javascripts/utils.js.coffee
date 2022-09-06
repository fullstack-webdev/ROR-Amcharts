Number.prototype.number_with_delimiter = (delimiter) ->
  number = this + ''
  delimiter = delimiter || ','
  split = number.split('.');
  split[0] = split[0].replace /(\d)(?=(\d\d\d)+(?!\d))/g, '$1' + delimiter
  split.join('.')

Number.prototype.with_delimiter = Number.prototype.number_with_delimiter

Number.prototype.non_negative = ->
  Math.max this, 0

Number.prototype.non_zero = ->
  if this == 0
    `undefined`
  else
    this

Number.prototype.format_time = () ->
  seconds = parseInt(this)
  days = Math.floor(seconds / 3600 / 24)
  hours = Math.floor((seconds - days * 3600 * 24) / 3600)
  mins = Math.floor((seconds - days * 3600 * 24 - hours * 3600) / 60)
  seconds = Math.floor(seconds - days * 3600 * 24 - hours * 3600 - mins * 60)
  ((if days then days + 'd' else '')) + ' ' + ((if hours then hours + 'h' else '')) + " " + ((if mins then mins + 'm' else '')) + " " + ((if seconds then seconds + 's' else ''))

Number.prototype.format_time_short = () ->
  seconds = parseInt(this)
  days = seconds / 3600 / 24
  hours = seconds / 3600
  mins = seconds / 60
  if days >= 1
    return days.round_to_decimal(1) + (if days >= 2 then ' days' else ' day')
  else if hours >= 1
    return hours.round_to_decimal(1) + (if hours >= 2 then ' hours' else ' hour')
  else if mins >= 1
    return mins.round_to_decimal(0) + (if mins >= 2 then ' minutes' else ' minute')
  else
    return seconds + (if seconds >= 2 then ' seconds' else ' second')

Number.prototype.round_to_decimal = (dec) ->
  dec = dec || 0
  value = parseFloat(this)
  Math.round(value * Math.pow(10, dec)) / Math.pow(10, dec)

Number.prototype.add_zero = (dec) ->
  value = parseInt(this)
  if value < 10
    return '0' + value
  else
    return value

binary_search = (arr, from, to, val, field) ->
  if to - from <= 1
    if Math.abs(arr[to][field] - val) < Math.abs(arr[from][field] - val)
      return arr[to]
    else
      return arr[from]
  else
    mid = Math.floor(Math.abs(to - from) / 2) + from;
    if arr[mid][field] < val
      return binary_search(arr, mid, to, val, field)
    else
      return binary_search(arr, from, mid, val, field)

Array.prototype.find_closest = (value, search_field) ->
  return binary_search(this, 0, this.length - 1, value, search_field)

binary_search1 = (arr, from, to, val, field, field2) ->
  if to - from <= 1
    if arr[to][field] <= val && arr[to][field2] >= val
      return arr[to]
    else if arr[from][field] <= val && arr[from][field2] >= val
      return arr[from]
    else
      return {}
  else
    mid = Math.floor(Math.abs(to - from) / 2) + from;
    if arr[mid][field] < val
      return binary_search1(arr, mid, to, val, field, field2)
    else
      return binary_search1(arr, from, mid, val, field, field2)

Array.prototype.find_between = (value, search_field1, search_field2) ->
  return binary_search1(this, 0, this.length - 1, value, search_field1, search_field2)

Array.prototype.first = () ->
  return this[0]

Array.prototype.last = () ->
  if this.length > 0 then this[this.length - 1] else null

window.isNoU = (val) ->
  typeof val == 'undefined' || val == null || val == ''