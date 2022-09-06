#
# Numeric conversions
#
class Numeric
  #### MASS ####
  def lbm
    self
  end

  def kg
    self / 2.2046225
  end

  def klbm
    self / 1000
  end

  def t
    self / (2.2046225 * 1000)
  end

  #### WEIGHT ####
  def lbm__ft
    self
  end

  def kg__m
    self * (1.kg / 1.m)
  end

  #### LENGTH ####
  def ft
    self
  end

  def m
    self * 0.3048
  end

  def in
    self * 12
  end

  def mm
    self * 304.8
  end

  #### AREA ####
  def ft2
    self
  end

  def m2
    self * 0.09290304
  end

  def in2
    self * 144
  end

  def mm2
    self * 92903.04
  end

  #### VOLUME ####
  def bbl
    self
  end

  def m3
    self * (1 / 6.2898106)
  end

  #### TEMPERATURE ####
  def R
    self
  end

  def K
    self * (1 / 1.8)
  end

  #### PRESSURE ####
  def psi
    self
  end

  def kPa
    self * (6.894757)
  end

  def ksi
    self / 1000
  end

  #### DYNAMIC VISCOSITY ####
  def cp
    self
  end

  def mPa_s
    self
  end

  #### DENSITY ####
  # def lbm__ft3
  #   self
  # end
  #
  # def lbm__gal
  #   self * (8.345405 / 62.42797)
  # end

  # def kg__m3
  #   self * (1000 / 62.42797)
  # end

  def ppg
    self
  end

  def g__cc
    self * (453.59 / 3785.41)
  end

  def kg__m3
    self * 99.77637
  end

  #### WATER DENSITY ####

  #### ENERGY ####
  def btu
    self
  end

  def kJ
    self * 1.055056
  end

  #### POWER ####
  def hp
    self
  end

  def ft_lbf__s
    self / 550
  end

  def W
    self * 745.700
  end

  #### MOLECULAR WEIGHT OF AIR ####
  def lbm_lbmol
    self
  end

  def kg_kmol
    self
  end

  #### PERMEABILITY ####
  def md
    self
  end

  # def mm2
  #   self / 1013.25
  # end

  ####
  def gpm
    self
  end

  def m3__min
    self * 0.00378541
  end

  #### FORCE ####
  def lbf
    self * 1.0
  end

  def daN
    self * 0.44482215
  end

  def klbf
    self / 1000.0
  end

  def KdaN
    self * 0.44482215 / 1000.0
  end

  #### WORK / ENERGY ####
  def ft_lbs
    self
  end

  def J
    self * 1.35581795
  end

  def N_m
    self * 1.35581795
  end

  #### YP ####
  def lbf__100_ft2
    self
  end

  def Pa
    self * 0.4788025898033584
  end

  #
  # Other
  #
  def from(unit)
    self / 1.send(unit.to_sym)
  end

  def convert(unit, type)
    self.send(:from, unit.to_sym).send(("#{type}Units").constantize::send(unit.to_sym))
  rescue => e
    Rails.logger.error e.inspect
    self
  end

  def convert_default(unit, type)
    self.send(:from, ("#{type}Units").constantize::send(unit.to_sym)).send(unit.to_sym)
  rescue => e
    Rails.logger.error e.inspect
    self
  end
end
