module ProgramsHelper
  def cache_key_for_programs
    count = Program.count
    max_updated_at = Program.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "programs/all-#{count}-#{max_updated_at}"
  end
end
