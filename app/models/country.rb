class Country < ActiveRecord::Base
    attr_accessible :id,
                    :iso,
                    :name

    has_many :states, order: "name ASC"
end
