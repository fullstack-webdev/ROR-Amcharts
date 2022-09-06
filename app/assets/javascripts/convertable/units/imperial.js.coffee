do ->
  unitConverter = window.unitConverter

  #### BASE UNITS ####
  BASE_UNITS = [
    'lbm'
    'ft'
    'ft2'
    'bbl'
    'R'
    'psi'
    'cp'
    'lbm-ft3'
    'btu'
    'hp'
    'lbm-lbmol'
    'md'
    'lbm/ft'
    'ppg'
    'gpm'
    'lbf'
    'ft-lbf'
  ]

  #### ADD IMPERIAL UNITS ####
  unitConverter.addSystem 'imperial'
  BASE_UNITS.forEach (unit) ->
    unitConverter.addUnit unit, unit, 1
    unitConverter.addConversion 'imperial', unit, unit

  unitConverter.addUnit 'lbm', 'klbm', (1 / 1000)
  unitConverter.addConversion 'imperial', 'klbm', 'klbm'

  unitConverter.addUnit 'lbf', 'klbf', (1 / 1000)
  unitConverter.addConversion 'imperial', 'klbf', 'klbf'

  unitConverter.addUnit 'psi', 'ksi', (1 / 1000)
  unitConverter.addConversion 'imperial', 'ksi', 'ksi'

  unitConverter.addUnit 'ft', 'in', 12
  unitConverter.addConversion 'imperial', 'in', 'in'

  unitConverter.addUnit 'ft2', 'in2', 144
  unitConverter.addConversion 'imperial', 'in2', 'in2'

  unitConverter.addUnit 'ft-lbf', 'kft-lbf', (1 / 1000)
  unitConverter.addConversion 'imperial', 'kft-lbf', 'kft-lbf'