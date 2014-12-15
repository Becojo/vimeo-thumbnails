require 'net/http'
require 'json'
require 'redis'

if ENV["REDISCLOUD_URL"]
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  $redis = Redis.new
end

def get_thumbnail_url(id)
  url = $redis.get(id)
  
  return url unless url.nil?
  
  result = Net::HTTP.get(URI.parse("http://vimeo.com/api/v2/video/#{id}.json"))
  json = JSON.parse(result)
  url = json[0]['thumbnail_large']
  
  $redis.set(id, url)
  
  url
end

get %r{([0-9]+)} do |id|
  url = get_thumbnail_url(id)
  redirect to(url), 301
end
