do ->
  numeric_table = {}
  systems_table = {}

  window.unitConverter = (value, unit) ->
    @value = parseFloat(value)
    @unit = unit

  unitConverter::canConvert = (targetUnit) ->
    if !@unit
      throw new Error('Incompatible units; unit does not exist')
    else if !numeric_table[targetUnit] || !numeric_table[targetUnit].multiplier
      throw new Error('Incompatible units; target unit is not valid')
    else
      true

  unitConverter::as = (targetUnit) ->
    this.convert targetUnit
    this

  unitConverter::is = (currentUnit) ->
    @unit = currentUnit
    this

  unitConverter::to = (system) ->
    system = system.toLowerCase()
    if !systems_table[system] || !systems_table[system][@unit]
      throw new Error('Incompatible units; unit system does not exist')
    this.convert systems_table[system][@unit]
    this

  unitConverter::val = ->
    @value

  unitConverter::toString = ->
    @value + ' ' + @unit

  unitConverter::convert = (targetUnit)->
    if this.canConvert targetUnit
      target = numeric_table[targetUnit]
      current = numeric_table[@unit]
      if target.base != current.base
        throw new Error('Incompatible units; cannot convert from "' + @unit + '" to "' + targetUnit + '"')
      @value = @value * target.multiplier / current.multiplier
      @unit = targetUnit

  unitConverter.addUnit = (baseUnit, actualUnit, multiplier) ->
    numeric_table[actualUnit] =
      base: baseUnit
      actual: actualUnit
      multiplier: multiplier

  unitConverter.addUnits = (units) ->
    units.forEach (unit) ->
      unitConverter.addUnit unit[0], unit[1], unit[2]

  unitConverter.addSystem = (unitSystem) ->
    systems_table[unitSystem] = systems_table[unitSystem] || {}

  unitConverter.addConversion = (system, baseUnit, actualUnit) ->
    systems_table[system] = systems_table[system] || {}
    systems_table[system][baseUnit] = actualUnit

  unitConverter.addConversions = (system, conversions) ->
    systems_table[system] = systems_table[system] || {}
    conversions.forEach (conversion) ->
      systems_table[system][conversion[0]] = conversion[1]

  window.$u = (value, unit) ->
    u = new (window.unitConverter)(value, unit)
    return u

  Number.prototype.convert = (unit, system) ->
    $u(parseFloat(this), unit).to(system)

  Number.prototype.convertable = (unit) ->
    $u(parseFloat(this), unit)

  Number.prototype.convert_default = (unit, system) ->
    system = system.toLowerCase()
    if !systems_table[system] || !systems_table[system][unit]
      throw new Error('Incompatible units; unit system does not exist')
    $u(parseFloat(this), systems_table[system][unit]).as(unit)

  String.prototype.unit = (system) ->
    systems_table[system.toLowerCase()][this].replace('3', '&sup3;').replace('-', '&middot;').replace('2', '&sup2;')

  return