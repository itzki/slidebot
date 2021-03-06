require File.expand_path('../boot', __FILE__)

['log/new.log', 'log/hot.log'].each do |log|
  IO.write(log, '2013-01-01') unless File.exist?(log)
end

Slideshare.setup
Slidebot.error_log = Textfile.new('error.log')

case Time.now.hour
when 0, 12
  mode = :hot
when 18
  mode = :popular
else
  mode = :new
end

slide = Slidebot::Slideshare.__send__(mode)
exit unless slide

slide.extend(Slidebot::Slideshare::Tweetable)

begin
  Twitter.update(slide.to_status(mode))
rescue => e
  Slidebot.error_log.append(Time.now, e.inspect, slide.inspect, '')
end

if mode == :popular
  Slidebot.log.append(slide.id)
else
  Slidebot.log.write(Slidebot::Slideshare.last_posted)
end
