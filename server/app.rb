require 'sinatra'
require 'sinatra/cross_origin'
require 'base64'
require 'open3'
require 'fileutils'

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
  wikiName = url.split('/').last;
  wikiDir = '%s_%s' % [wikiName, timestamp]
  
  # Clone wiki repo
  FileUtils.mkdir_p('wikis')
  Open3.popen3('cd wikis && git clone %s %s' % [url, wikiDir]) do |stdin, stdout, stderr, wait_thr|
    puts "stdout:" + stdout.read
    unless /exit 0/ =~ wait_thr.value.to_s
      halt 500  , stderr.read
    end
  end
  
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
    logFile = "%s/logs/%s" % [Dir.pwd, wikiDir]
    FileUtils.mkdir_p('logs')
    pid = Process.spawn('cd .. && ./wiki-links-validity.py -d server/wikis/%s/ -l %s' % [wikiDir, logFile])
    pids.store(url, pid.to_i + 1)
    logs.store(url, logFile)
  rescue Exception => e
    puts e.backtrace
    halt 500  , e.message
  end
end

get '/log/:url' do
  url = Base64.decode64(params['url']);
  begin
    IO.read(logs[url])
  rescue Exception => e
    puts e.message
  end
end
