#!usr/bin/ruby

module Enumerable

    def sum
        return self.inject(0){|accum, i| accum + i }
    end

    def mean
        return self.sum / self.length.to_f
    end

    def sample_variance
        m = self.mean
        sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
        return sum / (self.length - 1).to_f
    end

    def standard_deviation
        return Math.sqrt(self.sample_variance)
    end


    def mode
        sorted = self.sort
        a = Array.new
        b = Array.new
        sorted.each do |x|
            if a[x] == nil
                a << x # Add to list of values
                b << 1 # Add to list of frequencies
            else
                b[a[x]] += 1 # Increment existing counter
            end
        end
        maxval = b.max           # Find highest count
        where = b[maxval]       # Find index of highest count
        a[where]                 # Find corresponding data value
    end

end