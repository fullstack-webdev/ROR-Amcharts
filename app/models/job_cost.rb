class JobCost < ActiveRecord::Base
    attr_accessible :charge_at,
                    :charge_type,
                    :description,
                    :price,
                    :quantity,
                    :imported


    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :job
    validates :description, length: {maximum: 255}
    validates_presence_of :price
    validates_presence_of :quantity
    validates_presence_of :charge_type

    validates_uniqueness_of :description, :scope => [:job_id, :charge_at, :charge_type, :quantity, :price], :if => :is_import?

    belongs_to :company
    belongs_to :user
    belongs_to :job

    DAY = 1
    JOB = 2
    HOUR = 3
    ITEM = 4

    def is_import?
        self.imported
    end

    def self.job_total(job)

        return JobCost.where(:job_id => job.id).sum("price*quantity").to_f

        #costs = 0.0
        #if job.present?
        #    if job.job_costs.any?
        #        costs = job.job_costs.map { |jc| jc.price * jc.quantity }.reduce(:+)
        #    end
        #
        #
        #end
        #return costs
    end

    def self.charge_type_string(charge_type)
        case charge_type
            when DAY
                "Day"
            when JOB
                "Job"
            when HOUR
                "Hour"
            when ITEM
                "Item"
        end
    end

    # Temp method to populate costs
    def self.add_to_job job, cost
        if job.present?
            current_user = User.find(85)
            drilling_log = job.drilling_log
            if drilling_log.present? && drilling_log.below_rotary
                days = drilling_log.below_rotary.present? && drilling_log.above_rotary.present? ? ((drilling_log.above_rotary + drilling_log.below_rotary) / 24).ceil : 0

                job.job_costs.each do |jc|
                    jc.destroy
                end
                job_cost = JobCost.new
                job_cost.charge_type = JobCost::JOB
                job_cost.company = current_user.company
                job_cost.user = current_user
                job_cost.job = job
                job_cost.quantity = 1
                job_cost.price = days * cost
                job_cost.charge_at = job.created_at
                job_cost.save
                job.update_cost
            end
        end
    end

    def self.get_costs_per_day job

        costs = []

        times = {}
        job.job_costs.each do |jc|
            if !times.has_key? jc.charge_at
                times[jc.charge_at] = 0.0
            end

            times[jc.charge_at] += jc.price * jc.quantity
        end

        times.each do |key, value|
            costs << {cost: value, time: key, time_string: key.strftime('%b %d')}
        end

        times = times.sort_by { |key, value| key }

        costs
    end


end
