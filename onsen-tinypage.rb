#!/usr/bin/ruby -Kw

require 'open-uri'
require 'rexml/document'

W=Array["月","火","水","木","金"]

def get_xml(wday)
  xml = nil
  begin
    open("http://www.onsen.ag/data/regular_#{wday}.xml") { |io|
      xml = io.read
    }
  rescue
    retry
  end
  return xml
end

html = <<HTML
Content-Type: text/html; charset=utf-8

<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<TITLE>音泉簡易ページもどき</TITLE>
</HEAD>
<BODY bgcolor=green text=white>
HTML

1.upto(5) { |wday|
  html << "<A NAME=\"#{wday}\"><H3>#{W[(wday -1)]}曜日</H3></A><TABLE border=1 bordercolor=white rules=all width=100%>"
  data = REXML::Document.new(get_xml(wday))
  data.elements.each("data/regular/program") { |element|
    title = element.get_text("title")
    header = element.get_text("titleHeader")
    image = element.get_text("imagePath")
    no = element.get_text("number").to_s.strip
    detail = element.get_text("detailURL").to_s.strip
    update = element.get_text("isNew").to_s.to_i
    content_url = element.get_text("contents/fileUrl").to_s.strip
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
print html
