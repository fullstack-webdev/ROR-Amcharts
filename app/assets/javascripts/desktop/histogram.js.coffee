window.extend_histogram_data = (histogram) ->
  extended = []
  prev = 0
  ten_percent = Math.ceil(histogram['ten_per'] / 15) * 0.25
  fifty_percent = Math.ceil(histogram['fifty_per'] / 15) * 0.25
  ninety_percent = Math.ceil(histogram['ninety_per'] / 15) * 0.25
  histogram['data'].forEach (record) ->
    if prev + 0.25 == record.op_time
      extended.push record
      prev = record.op_time
    else
      if record.op_time <= fifty_percent
        i = parseInt(prev / 0.25) + 1
        while i <= parseInt(record.op_time / 0.25)
          extended.push
            op_time: 0.25 * i
            op_count: 0
          i++
        prev = record.op_time
      else
        i = parseInt(prev / 0.25) + 1
        while i <= parseInt(record.op_time / 0.25)
          extended.push
            op_time: 0.25 * i
            op_count: 0
          if i - parseInt(prev / 0.25) > 3
            break
          i++
        extended.push record
        prev = record.op_time
  extended

window.full_histogram_data = (histogram) ->
  extended = []
  prev = 0
  ten_percent = Math.ceil(histogram['ten_per'] / 15) * 0.25
  fifty_percent = Math.ceil(histogram['fifty_per'] / 15) * 0.25
  ninety_percent = Math.ceil(histogram['ninety_per'] / 15) * 0.25
  histogram['data'].forEach (record) ->
    if prev + 0.25 == record.op_time
      extended.push record
      prev = record.op_time
    else
        i = parseInt(prev / 0.25) + 1
        while i <= parseInt(record.op_time / 0.25)
          extended.push
            op_time: 0.25 * i
            op_count: 0
          i++
        prev = record.op_time
  extended

window.histogram_percent = (per) ->
  Math.ceil(per / 15) * 0.25