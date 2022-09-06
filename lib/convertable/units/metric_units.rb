#
# Corresponding METRIC to SI units table
# Returns default unit
#
# Naming conventions:
#     _ : * ( for example: mPa_sm -> Pa*s )
#    __ : / ( for example: kg__m3 -> kg/m3 )
module MetricUnits
  class << self
    #### MASS ####
    def mass
      :kg
    end

    alias :pound :mass
    alias :lb :mass
    alias :lbm :mass

    def klbm
      :t
    end

    alias :klbs :klbm

    #### WEIGHT ####
    def weight
      :kg__m
    end

    alias :lbm__ft :weight

    #### LENGTH ####
    def length
      :m
    end

    alias :feet :length
    alias :ft :length

    def in
      :mm
    end

    #### AREA ####
    def area
      :m2
    end

    alias :acre :area
    alias :ft2 :area

    def in2
      :mm2
    end

    #### VOLUME ####
    def volume
      :m3
    end

    alias :barrel :volume
    alias :bbl :volume

    def gpm
      :m3__min
    end

    #### TEMPERATURE ####
    def temperature
      :K
    end

    alias :rankine :temperature
    alias :R :temperature

    #### PRESSURE ####
    def pressure
      :kPa
    end

    alias :pounds_per_square_inch :pressure
    alias :psi :pressure

    def ksi
      :Mpa
    end

    #### DYNAMIC VISCOSITY ####
    def dynamic_viscosity
      :mPa_s
    end

    alias :cp :dynamic_viscosity
    alias :centipoise :dynamic_viscosity

    #### DENSITY ####
    # def density
    #   :kg__m3
    # end
    #
    # alias :lbm__ft3 :density
    # alias :lbm__gal :density

    def ppg
      :kg__m3
    end

    #### WATER DENSITY ####
    def water_density
      :kg__m3
    end

    #### ENERGY ####
    def energy
      :kJ
    end

    alias :btu :energy

    #### POWER ####
    def power
      :W
    end

    alias :ft_lbf__s :power

    #### MOLECULAR WEIGHT OF AIR ####
    def molecular_weight_of_air
      :kg_kmol
    end

    alias :lbm_lbmol :molecular_weight_of_air

    #### PERMEABILITY ####
    def permeability
      :mm2
    end

    alias :md :permeability

    #### FORCE ####
    def lbf
      :daN
    end

    def klbf
      :KdaN
    end

    #### WORK / ENERGY ####
    def ft_lbs
      :N_m
    end

    #### YP ####
    def Pa
      :lbf__100_ft2
    end
  end
end
