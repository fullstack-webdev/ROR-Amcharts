module EventWarningsHelper
  def cache_key_for_warnings job
    count = job.event_warnings.count
    max_updated_at = EventWarning.maximum(:updated_at, conditions: ['job_id = ?', @job.id]).try(:utc).try(:to_s, :number)
    "jobs/#{job.id}/warnings/#{count}-#{max_updated_at}"
  end
end
