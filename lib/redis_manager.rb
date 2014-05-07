class EyeControl::RedisManager
  include Celluloid::IO
  include Celluloid::Logger
  include Celluloid::Notifications

  def initialize
    @redis = ::Redis.new(:driver => :celluloid)
    @redis_sub = ::Redis.new(:driver => :celluloid)

    async.run
  end

  def get_processes
    @redis.hgetall("eye:processes").map{|k,v| JSON.parse(v)}
  end

  def broadcast msg
    @redis.publish ["eye", "command", msg["event"]].join(":"), msg.to_json
  end

  def run
    @redis_sub.subscribe("eye:process:state") do |on|
      on.subscribe do |channel, subscriptions|
        info "Subscribed to #{channel}"
      end

      on.message do |channel, msg|
        info "EVENT #{channel} #{msg}"
        publish "state_change", JSON.parse(msg)
      end
    end
  end
end