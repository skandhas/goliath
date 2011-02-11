module Goliath
  class Env < Hash

    def initialize
      self[:start_time] = Time.now.to_f
      self[:time] = Time.now.to_f
      self[:trace] = []
    end

    def trace(name)
      self[:trace].push [name, "%.2f" % ((Time.now.to_f - self[:time]) * 1000)]
      self[:time] = Time.now.to_f
    end

    def trace_stats
      self[:trace] + [['total', self[:trace].collect { |s| s[1].to_f }.inject(:+).to_s]]
    end

    def stream_send(data)
      self[Goliath::Request::STREAM_SEND].call(data)
    end

    def stream_close
      self[Goliath::Request::STREAM_CLOSE].call
    end

    def respond_to?(name)
      if self.has_key?(name.to_s) || (!self['config'].nil? && self['config'].has_key?(name.to_s))
        true
      else
        super
      end
    end

    def method_missing(name, *args, &blk)
      if self.has_key?(name.to_s)
        self[name.to_s]

      elsif !self['config'].nil? && self['config'].has_key?(name.to_s)
        self['config'][name.to_s]

      else
        super(name, *args, &blk)
      end
    end
  end
end
