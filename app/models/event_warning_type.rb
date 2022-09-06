class EventWarningType < ActiveRecord::Base
    extend Enumerize

    attr_accessible :name,
                    :severity,
                    :category,
                    :description,
                    :resolution,
                    :warning_id

    has_many :event_warnings, dependent: :destroy

    before_save :default_values

    validates :name, presence: true
    validates :severity, presence: true
    validates :category, presence: true
    validates :description, presence: true
    validates :resolution, presence: true
    validates :warning_id, presence: true
    validates_uniqueness_of :warning_id

    enumerize :severity, in: Enum::EventWarningType::SEVERITY[:options],
              default: Enum::EventWarningType::SEVERITY[:default]
    #enumerize :category, in: Enum::EventWarningType::CATEGORY[:options]

    def default_values
    end

    def self.categories
        features = CompanyFeature.possible_features
        categories = []
        features.each do |f|
            categories << [CompanyFeature.feature_to_string(f), f]
        end

        return categories
    end

    def category_label
        CompanyFeature.feature_to_string(self.category.to_i)
    end

    def self.severity_filter
        options = EventWarningType.severity.options

        options.each do |o|
            if o[0] == "Low"
                o[0] = "All Warnings"
            elsif o[0] == "Moderate"
                o[0] = "Moderate + High"
            elsif o[0] == "High"
                o[0] = "Only High"
            end

        end
    end

end
