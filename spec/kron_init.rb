require 'lib/kron.rb'
require 'time'

TIME_FORMAT = '%a %b %d, %Y %I:%M %p'

module Kron
  class Runner
    def jobs
      @jobs
    end
  end

  class KronJob
    attr_reader :current_time, :minute
    def set_time_now(current_time)
      ct = (current_time.kind_of?(Time) ? current_time : Time.parse(current_time))
      @current_time = Time.mktime(ct.year, ct.month, ct.day, ct.hour, ct.min)
    end

    def time_now
      # need to define for testing
      @current_time ? @current_time : Time.now
    end
  end
end
