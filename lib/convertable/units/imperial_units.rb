#
# Returns SI default unit
#
# Naming conventions:
#     _ : * ( for example: mPa_sm -> Pa*s )
#    __ : / ( for example: kg__m3 -> kg/m3 )
module ImperialUnits
  class << self
    #### MASS ####
    def mass
      :lbm
    end

    alias :pound :mass
    alias :lb :mass
    alias :lbm :mass

    def klbm
      :klbm
    end

    alias :klbs :klbm

    #### WEIGHT ####
    def weight
      :lbm__ft
    end

    alias :lbm__ft :weight
    alias :lb__ft :weight
    alias :lbs__ft :weight

    #### LENGTH ####
    def length
      :ft
    end

    alias :feet :length
    alias :ft :length

    def in
      :in
    end

    #### AREA ####
    def area
      :ft2
    end

    alias :acre :area
    alias :ft2 :area

    def in2
      :in2
    end

    #### VOLUME ####
    def volume
      :bbl
    end

    alias :barrel :volume
    alias :bbl :volume

    def gpm
      :gpm
    end

    #### TEMPERATURE ####
    def temperature
      :R
    end

    alias :rankine :temperature
    alias :R :temperature

    #### PRESSURE ####
    def pressure
      :psi
    end

    alias :pounds_per_square_inch :pressure
    alias :psi :pressure

    def ksi
      :ksi
    end

    #### DYNAMIC VISCOSITY ####
    def dynamic_viscosity
      :cp
    end

    alias :cp :dynamic_viscosity
    alias :centipoise :dynamic_viscosity

    #### DENSITY ####
    # def density
    #   :lbm__ft3
    # end
    #
    # alias :lbm__ft3 :density
    # alias :lbm__gal :density

    def ppg
      :ppg
    end

    #### WATER DENSITY ####
    def water_density
      :lbm_ft3
    end

    #### ENERGY ####
    def energy
      :btu
    end

    alias :btu :energy

    #### POWER ####
    def power
      :hp
    end

    alias :ft_lbf__s :power
    alias :hp :power

    #### MOLECULAR WEIGHT OF AIR ####
    def molecular_weight_of_air
      :lbm_lbmol
    end

    alias :lbm_lbmol :molecular_weight_of_air

    #### PERMEABILITY ####
    def permeability
      :md
    end

    alias :md :permeability

    #### FORCE ####
    def lbf
      :lbf
    end

    def klbf
      :klbf
    end

    #### WORK / ENERGY ####
    def ft_lbs
      :ft_lbs
    end

    #### YP ####
    def lbf__100_ft2
      :lbf__100_ft2
    end
  end
end
