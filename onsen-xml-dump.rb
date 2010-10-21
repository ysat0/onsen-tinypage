#!/usr/bin/ruby -Kw
# -*- coding: utf-8 -*-

require 'net/http'
require 'digest/md5'
require 'date'

Now = DateTime.now

Net::HTTP.version_1_2
def get_xml(wday)
  xml = nil
  cookie = {}
  now = DateTime.now
  code = Digest::MD5.hexdigest("onsen#{now.wday}#{now.day}#{now.hour}")
  begin
    Net::HTTP.start("onsen.ag") { |http|
      resp = http.get("/")
      resp['Set-Cookie'].split(';').each { |c|
        val = c.split('=')
        cookie[val[0]] = val[1]
      }
    }
    Net::HTTP.start("onsen.ag") { |http|
      resp = http.post("/getXML.php", "file_name=regular_#{wday}&code=#{code}", 
                       {"Cookie" => "PHPSESSID=#{cookie['PHPSESSID']}", "Referer" => "http://onsen.ag"})
      xml = resp.body
    }
  rescue
    retry
  end
  return xml
end

1.upto(5) { |wday|
  puts get_xml(wday)
}
