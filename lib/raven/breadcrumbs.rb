module Raven
  class Breadcrumb
    attr_accessor :category, :data, :message, :level, :timestamp, :type

    def initialize
      @category = nil
      @data = {}
      @level = nil
      @message = nil
      @timestamp = Time.now.to_i
      @type = nil
    end

    def to_hash
      {
        :category => @category,
        :data => @data,
        :level => @level,
        :message => @message,
        :timestamp => @timestamp,
        :type => @type
      }
    end
  end
end

module Raven
  class BreadcrumbBuffer
    include Enumerable

    attr_accessor :buffer

    def self.current
      Thread.current[:sentry_breadcrumbs] ||= new
    end

    def self.clear!
      Thread.current[:sentry_breadcrumbs] = nil
    end

    def initialize(size = 100)
      @buffer = Array.new(size)
      @last = 0
    end

    def record(crumb = nil)
      if block_given?
        crumb = Breadcrumb.new if crumb.nil?
        yield(crumb)
      end
      @buffer[@last] = crumb
      @last += 1
      @last = 0 if @last == @buffer.size
    end

    def members
      @buffer.last(@buffer.size - @last).compact + @buffer.first(@last)
    end

    def peek
      members.last
    end

    def each(&block)
      members.each(&block)
    end

    def empty?
      !members.any?
    end

    def to_hash
      {
        :values => members.map(&:to_hash)
      }
    end
  end
end
