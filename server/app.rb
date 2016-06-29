require 'sinatra'
require 'sinatra/cross_origin'
require 'base64'

set :port, 8081
set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end

get '/' do
  "the time where this server lives is #{Time.now}
    <br /><br />check out your <a href=\"/agent\">user_agent</a>"
end

get '/agent' do
  "you're using #{request.user_agent}"
end

pids = Hash.new
logs = Hash.new

get '/validate/:url' do
  url = Base64.decode64(params['url'])
  timestamp = params['timestamp']
  
  # Clone wiki repo
  Process.spawn('mkdir wikis')
  Process.wait
  Process.spawn('cd wikis && git clone %s' % url)
  Process.wait
  
  # Kill previous process if exists
  pid = pids[url]
  begin
    if pid != nil
       Process.kill('KILL', pid)
    end
  rescue Exception
  end

  # Execute validation process
  begin
    wikiName = url.split('/').last;
    logFile = "%s_%s" % [wikiName, timestamp]
    pid = fork do
      exec('cd .. && ./wiki-links-validity.py -d server/wikis/%s/ -l %s' % [wikiName, logFile])
    end
    pids.store(url, pid.to_i + 3)
    logs.store(url, logFile)
  rescue Exception
  end
end

get '/log/:url' do
  url = Base64.decode64(params['url']);
  IO.read("../%s" % logs[url])
end
