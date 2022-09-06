module RigsHelper
  def cache_key_for_rigs
    count = Rig.count
    max_updated_at = Rig.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "rigs/all-#{count}-#{max_updated_at}"
  end
end
