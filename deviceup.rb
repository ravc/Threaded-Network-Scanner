require 'net/ping'
require 'pushbullet'

def up?(id)
    whitelist = [1,2,3]
    time1 = Time.now
    check = Net::Ping::External.new('192.168.1.'+id.to_s)
    if check.ping? && (whitelist.include?(id) == false)
        return id
    else
        return 0
    end
end
def sendtopush(ip)
    client = Pushbullet::Client.new('your api key here')
    ip.each {|x| client.push_note_to('pushbullet email','New Device', '192.168.1.' + x.to_s)}
end

queue = Queue.new
notified = []
l = 0

while true
    (1..255).to_a.each{|x| queue.push x }
    threads = (1..254).map do |i|
        Thread.new(i) do |i|
            begin
                while x = queue.pop(true)
                    if up?(i) != 0 && (notified.include?(i) == false)
                        notified.push(up?(i))
                    end
                end
            rescue ThreadError
            end
        end
    end

    threads.each {|t| t.join}

    if l != notified.length
        puts notified
        sendtopush(notified)
        l = notified.length
    end
end
