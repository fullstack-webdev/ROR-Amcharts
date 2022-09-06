class State < ActiveRecord::Base
    attr_accessible :id,
                    :country_id,
                    :iso,
                    :name
end
