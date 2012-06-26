require "kron/version"
require 'time'

module Kron

  class Runner

    attr_reader :interval

    LOG_FILE = "#{Dir.pwd}/log/kron.log"

    def initialize(interval=60)
      @th       = nil
      @jobs     = []
      @interval = interval
      if File.exist?(LOG_FILE)
        require 'logger'
        @logger   = Logger.new(LOG_FILE, 'weekly')
      end
      yield self if block_given?
    end

    def schedule
      @jobs.map { |job| job.schedule }
    end

    def set_interval(interval)
      @interval = interval
    end

    def running?
      @th
    end

    def start
      if @th and @th.alive?
        'Kron Is Already Running'
      else
        @th = Thread.new do
                while true
                  begin
                    @jobs.each do |job|
                      db_connect
                      if job.run?
                        job.run
                      end
                      @jobs.delete(job) unless job.has_pending_jobs?
                    end
                  rescue Exception => e 
                    @logger.info(e.message) if @logger
                  end
                  sleep @interval
                end
              end
        (@th ? 'Started Kron' : 'Kron Did NOT Start')
      end
      self
    end

    def stop
      if @th and @th.alive?
        @th.kill
      else
        'Can not stop Kron, it was not running'
      end
      @th=nil
    end

    def destroy
      stop
      @jobs.clear
    end

    def add_job(job)
      @jobs << job
    end
    alias :<< :add_job

    def number_of_jobs
      @jobs.size
    end

    private
    def db_connect
      if defined?(ActiveRecord)
        ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
      #elsif defined?(DataMapper) ... etc
      end
    end
  end

  class KronJob

    DTM_FORMAT = '%b %e, %Y %l:%M %p'
    MIN_FORMAT = '%l:%M %p'
    DAYNAMES   = Date::DAYNAMES.map { |x| x.downcase }
    MONTHNAMES = Date::MONTHNAMES.compact.map { |x| x.downcase }

    def initialize
      @minutes    = nil
      @days       = {}
      @month_days = {}
      @months     = []
      @once_days  = []
      @ats        = []
      @on_thes    = []
      @ons        = []
    end

    def has_pending_jobs?
      (@has_pending_jobs or @once_days.size > 0)
    end

    def schedule
      a=[]
      a << "#{@minutes / 60} Minutes" if @minutes
      @days.each do |day, times|
        times.each do |tm|
          a << (tm.kind_of?(Integer) ? "#{day.capitalize} every #{tm / 60} Minute(s)" : "#{day.capitalize} at #{tm}")
        end
      end
      @month_days.each do |month, day_hash|
        day_hash.each { |day, times| a << times.each { |tm| "#{month} on the #{day.capitalize} at #{tm}" } }
      end
      Schedule.new(description, a)
    end

    def run
      @block.call
    end

    def time_now # need to define for testing
      Time.now
    end

    def run?
      now = time_now
      @days.each do |day, times|
        set_has_jobs
        next unless day == now.strftime('%A').downcase
        times.each do |time|
          if time.kind_of?(Integer)
            if @minute == now.strftime('%M')
              @minute = (now + @minutes).strftime('%M')
              return true
            end
          else
            return true if time == now.strftime(MIN_FORMAT)
          end
        end
      end

      set_has_jobs if @minute
      if @minute == now.strftime('%M')
        @minute = (now + @minutes).strftime('%M')
        return true
      end

      @month_days.each do |month, day_hash|
        set_has_jobs
        next unless month == now.strftime('%B').downcase
        day_hash.each do |day, times|
          next unless (day == now.strftime('%A').downcase or day.to_i == now.strftime('%e').to_i ) # allow day name or date
          return true if times.include?(now.strftime(MIN_FORMAT))
        end
      end
      @once_days.each do |day| 
        if day == now.strftime(DTM_FORMAT)
          @once_days.delete(day)
          return true
        end
      end
      false
    end

    def every(*args, &block)
      @block = block
      args.each do |arg|
        ar = arg.to_s.downcase
        if arg.kind_of?(Integer)
          @minutes = arg
          @minute  = (time_now + arg).strftime('%M')
        elsif DAYNAMES.include?(ar)
          @days[ar]=[]
        elsif ar == 'day'
          DAYNAMES.each { |day| @days[day]=[] }
        elsif MONTHNAMES.include?(ar)
          @months << ar
        elsif ar == 'month'
          MONTHNAMES.each { |month| @months << month }
        end
      end
      define_times
      self
    end

    # run once "on('date parsible string')"
    def on(*args, &block)
      @block = block
      @ons = args
      self
    end

    # for use with month descriptions
    def on_the(*args, &block)
      @block = block
      @on_thes = args.map { |arg| arg.to_s }
      self
    end

    def at(*args, &block)
      @block = block
      args.each { |arg| @ats << parse_minutes(arg) }
      define_times
      self
    end

    def description
      (@description ? @description : '"No Desc."')
    end

    def set_description(d)
      @description = d
      self
    end

    private
    def set_has_jobs
      @has_pending_jobs = true
    end

    def define_times
      @days.each do |key, day|
        @ats.each { |at| day << at }
        day << @minutes if @minutes
      end
      @months.each do |month|
        @month_days[month] ||= {}
        @on_thes.each do |day_num|
          @month_days[month][day_num] ||= []
          @ats.each { |arg| @month_days[month][day_num] << parse_minutes(arg) }
        end
      end
      @ons.each do |day|
        @ats.each do |arg|
          tm = Time.parse("#{day} #{parse_minutes(arg)}")
          if tm > Time.now
            @once_days << tm.strftime(DTM_FORMAT)
          else
            puts "Error: Tried To Add A Time In The Past... \"#{tm.strftime(DTM_FORMAT)}\""
          end
        end
      end
    end

    def parse_minutes(arg)
      time, am_pm = arg.split(' ')
      hour, minute = time.split(':')

      hour   = (hour.size == 1 ? " #{hour}" : hour) 
      minute = (minute ? minute : '00') 
      am_pm  = (am_pm.to_s == '' ? 'am' : am_pm.upcase) 

      "#{hour}:#{minute} #{am_pm}"
    end

    class Schedule
      attr_reader :description, :jobs
      def initialize(desc, jobs)
        @description = desc
        @jobs        = jobs
      end
    end
  end
end
