class BhaItem < ActiveRecord::Base
    attr_accessible :inner_diameter,
                    :outer_diameter,
                    :length,
                    :up,
                    :down,
                    :asset_type


    acts_as_tenant(:company)

    validates :company, presence: true
    validates :bha, presence: true

    belongs_to :company
    belongs_to :bha


    BIT = 1
    MOTOR = 2
    STABILIZER = 3
    UBHO_SUB = 4
    DRILL_COLLAR = 5
    BULL_NOSE = 6
    DRILL_PIPE = 7
    FLOAT_SUB = 8
    HWDP = 9
    CROSS_OVER = 10
    HOLE_OPENER = 11
    FLEX_JOINT = 12
    JARS = 13
    MILLS = 14
    ROTAERY_STEERABLE = 15
    ROLLER_REAMER = 15
    OTHER = 20

    BATTERY = 50
    GAMMA = 51
    PULSER = 52

    def self.add(bha, id, od, length, up, down, asset_type, ordering)

        bha_item = BhaItem.new
        bha_item.bha = bha
        bha_item.company = bha.company
        bha_item.inner_diameter = id
        bha_item.outer_diameter = od
        bha_item.length = length
        bha_item.ordering = ordering
        bha_item.up = up
        bha_item.down = down
        bha_item.asset_type = asset_type

        bha_item.save!
        bha_item

    end

    def self.options
        options = []
        options << ["None", 0]
        options << ["", -1]

        options << ["Pin Connections ->", -1]
        options << ["3.5 IF", 1]
        options << ["3.5 REG", 2]
        options << ["4.5 FH", 3]
        options << ["4.5 IF", 4]
        options << ["4.5 REG", 5]
        options << ["4.5 XH", 6]
        options << ["4 FH", 7]
        options << ["4 IF", 8]
        options << ["6.625 REG", 9]
        options << ["NC56", 10]
        options << ["", -1]

        options << ["Box Connections ->", -1]
        options << ["3.5 IF", 11]
        options << ["3.5 REG", 12]
        options << ["4.5 FH", 13]
        options << ["4.5 IF", 14]
        options << ["4.5 REG", 15]
        options << ["4.5 XH", 16]
        options << ["4 FH", 17]
        options << ["4 IF", 18]
        options << ["6.625 REG", 19]
        options << ["NC56", 20]
    end

    def self.connection_string connection
        base_string = ''

        case connection
            when 0
                base_string = "None"
            when 1
                base_string = "3.5 IF"
            when 11
                base_string = "3.5 IF"
            when 2
                base_string = "3.5 REG"
            when 12
                base_string = "3.5 REG"
            when 3
                base_string = "4.5 FH"
            when 13
                base_string = "4.5 FH"
            when 4
                base_string = "4.5 IF"
            when 14
                base_string = "4.5 IF"
            when 5
                base_string =  "4.5 REG"
            when 15
                base_string =  "4.5 REG"
            when 6
                base_string =  "4.5 XH"
            when 16
                base_string =  "4.5 XH"
            when 7
                base_string =  "4 FH"
            when 17
                base_string =  "4 FH"
            when 8
                base_string = "4 IF"
            when 18
                base_string = "4 IF"
            when 9
                base_string = "6.625 REG"
            when 19
                base_string = "6.625 REG"
            when 10
                base_string = "NC56"
            when 20
                base_string = "NC56"
        end

        if connection == 0
            return base_string
        elsif connection > 10
            return base_string + " B"
        else
            return base_string + " P"
        end
    end

    def self.type_options
        options = []
        options << ["Type...", -1]
        options << ["Bit", BhaItem::BIT]
        options << ["Motor", BhaItem::MOTOR]
        options << ["Stabilizer", BhaItem::STABILIZER]
        options << ["UBHO Sub", BhaItem::UBHO_SUB]
        options << ["Drill Collar", BhaItem::DRILL_COLLAR]
        options << ["Bull Nose", BhaItem::BULL_NOSE]
        options << ["Drill Pipe", BhaItem::DRILL_PIPE]
        options << ["Float Sub", BhaItem::FLOAT_SUB]
        options << ["HWDP", BhaItem::HWDP]
        options << ["X-Over", BhaItem::CROSS_OVER]
        options << ["Hole Opener", BhaItem::HOLE_OPENER]
        options << ["Flex Joint", BhaItem::FLEX_JOINT]
        options << ["Jars", BhaItem::JARS]
        options << ["Mill", BhaItem::MILLS]
        options << ["Rotary Steerable", BhaItem::ROTAERY_STEERABLE]
        options << ["Roller Reamer", BhaItem::ROLLER_REAMER]
        options << ["Other", BhaItem::OTHER]

    end

end
