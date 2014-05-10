rails_env   = ENV['RAILS_ENV']
rails_root  = ENV['RAILS_ROOT'] || File.expand_path(File.join(File.dirname(__FILE__), '..'))

God.watch do |w|
  w.dir       = "#{rails_root}/node"
  w.name      = "node-proxy"
  w.group     = "node"
  w.interval  = 10.seconds
  w.start     = "npm start"
  w.env       = {'NODE_ENVIRONMENT' => 'production'}
  w.stop      = "killall node"
  w.log       = "#{rails_root}/log/node-proxy.log"

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end  
end



workers = 
{
  "*" => 1
}
  
RESQUE_PROCESSORS = []
workers.each_pair do |queue, num_workers|
  idx = RESQUE_PROCESSORS.size
  1.upto(num_workers).each do |i|
    RESQUE_PROCESSORS.push([i + idx, queue]) 
  end
end

RESQUE_PROCESSORS.each do |resque_id, resque_queues|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "resque-#{resque_id}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.env      = {"QUEUES"=>resque_queues, "RAILS_ENV"=>rails_env, "BUNDLE_GEMFILE"=>"#{rails_root}/Gemfile"}
    w.start    = "bundle exec rake -f #{rails_root}/Rakefile environment resque:work"
    w.log      = "#{rails_root}/log/resque-#{resque_id}.log"

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end

