class QueryConstraint < Object
    attr_accessor :id,
                  :name,
                  :constraint_type,
                  :value


    VALUE = 1
    VALUE_RANGE = 2
    DATE_RANGE = 3
    INCLUSION = 4


    def initialize(id, name, constraint_type)
        @id = id
        @name = name
        @constraint_type = constraint_type
    end
end

class Query < Object
    attr_accessor :constraints

    @constraints


    def initialize
        @constraints = {'general' => [],
                        'warnings' => [],
                        'well characteristics' => [],
                        'well design' => []}

        add_general_constraints
        add_warning_constraints
        add_well_characteristics_constraints
        add_well_design_constraints
    end

    def add_general_constraints
        @constraints["general"].push QueryConstraint.new("md", "Total Measured Depth", QueryConstraint::VALUE_RANGE)
        #@constraints["general"].push QueryConstraint.new("ld", "Total Lateral Depth", QueryConstraint::VALUE_RANGE)
        @constraints["general"].push QueryConstraint.new("time", "Well Time (Days)", QueryConstraint::VALUE_RANGE)
        @constraints["general"].push QueryConstraint.new("start", "Well Start", QueryConstraint::DATE_RANGE)
        @constraints["general"].push QueryConstraint.new("rig", "Rig", QueryConstraint::VALUE)
        @constraints["general"].push QueryConstraint.new("county", "County", QueryConstraint::VALUE)
        @constraints["general"].push QueryConstraint.new("field", "Field", QueryConstraint::VALUE)
        @constraints["general"].push QueryConstraint.new("dc", "Drilling Company", QueryConstraint::VALUE)
        @constraints["general"].push QueryConstraint.new("fc", "Fluid Company", QueryConstraint::VALUE)
    end

    def add_warning_constraints
        @constraints["warnings"].push QueryConstraint.new("warning_depth", "Warning Depth", QueryConstraint::VALUE_RANGE)
        EventWarningType.all.each do |ew|
            @constraints["warnings"].push QueryConstraint.new("ew#{ew.warning_id}", ew.name, QueryConstraint::INCLUSION)
        end
    end

    def add_well_characteristics_constraints
        @constraints["well characteristics"].push QueryConstraint.new("rop", "Average ROP", QueryConstraint::VALUE_RANGE)
    end

    def add_well_design_constraints
        @constraints["well design"].push QueryConstraint.new("bit_size", "Bit Size", QueryConstraint::VALUE)
        @constraints["well design"].push QueryConstraint.new("bit_make", "Bit Make", QueryConstraint::VALUE)
        @constraints["well design"].push QueryConstraint.new("bit_serial", "Bit Serial", QueryConstraint::VALUE)
        @constraints["well design"].push QueryConstraint.new("casing_size", "Casing Size", QueryConstraint::VALUE)
        @constraints["well design"].push QueryConstraint.new("casing_depth", "Casing Depth", QueryConstraint::VALUE)
        @constraints["well design"].push QueryConstraint.new("fluid", "Fluid Type", QueryConstraint::VALUE)
    end

end