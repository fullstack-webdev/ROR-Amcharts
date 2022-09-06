module WellsHelper
  def cache_key_for_wells
    count = Well.completed.count
    max_updated_at = Well.completed.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "wells/all-#{count}-#{max_updated_at}"
  end
end
