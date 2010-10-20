#!/usr/bin/ruby -Kw
# -*- coding: utf-8 -*-

require 'open-uri'
require 'rexml/document'
require 'mechanize'
require 'digest/md5'
require 'date'

W = Array["月曜日","火曜日","水曜日","木曜日","金曜日"]
Now = DateTime.now

def get_xml(agent, wday)
  code = Digest::MD5.hexdigest("onsen#{Now.wday}#{Now.day}#{Now.hour}")
  xml = nil
  begin
    xml = agent.post("http://onsen.ag/getXML.php", "code" => code, "file_name" => "regular_#{wday}")
  rescue
    retry
  end
  return xml.body
end

html = (ENV['REQUEST_METHOD']) ? "Content-Type: text/html; charset=utf-8\n\n" : ""

html << <<HTML
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<TITLE>音泉簡易ページもどき</TITLE>
</HEAD>
<BODY bgcolor=green text=white>
HTML

html << "<TABLE><TR>"
1.upto(5) { |wday|
  html << "<TD><A href=\"##{wday}\">#{W[wday -1]}</A></TD>"
}
html << "</TR></TABLE>\n"

agent = Mechanize.new
agent.get("http://onsen.ag")

1.upto(5) { |wday|
  html << "<A NAME=\"#{wday}\"><H3>#{W[wday -1]}</H3></A><TABLE border=1 bordercolor=white rules=all width=100%>"
  data = REXML::Document.new(get_xml(agent, wday))
  data.elements.each("data/regular/program") { |element|
    title = element.get_text("title")
    header = element.get_text("titleHeader")
    image = element.get_text("imagePath")
    no = element.get_text("number").to_s.strip
    detail = element.get_text("detailURL").to_s.strip
    update = element.get_text("isNew").to_s.to_i
    content_url = ""
    element.each_element('contents') { |contents|
      if contents.get_text("isAdvertize").to_s == '0' then
        url = contents.get_text("fileUrl").to_s
        content_url = url.strip
        break if url !~ /cm_onsen/
      end
    }
    detail = "http://onsen.ag/program/#{header}/index.html" if detail.empty?
    play = (no.empty? || content_url.empty?) ? "" : "<A href=\"#{content_url}\"><INPUT type=\"submit\" value=\"第#{no}回を再生\"></A>"
    new = (update == 0) ? "" : "&nbsp;<FONT size=-1 color=red>new</FONT>"
    html << <<ITEM
<TR>
  <TD><IMG src="http://onsen.ag/#{image}" alt="#{header}"></IMG></TD>
  <TD width=100%>#{title}#{new}</TD>
  <TD>
    <TABLE>
      <TR><TD><A href="#{detail}" target="_blank"><INPUT type=\"submit\" value=\"番組紹介\"></A></TD></TR>
      <TR><TD>#{play}</TD></TR>
    </TABLE>
  </TD>
</TR>
ITEM
  }
  html << "</TABLE>\n"
}
html << "</BODY></HTML>"
puts html
