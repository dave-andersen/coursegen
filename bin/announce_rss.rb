#!/usr/bin/env ruby

require 'yaml'
require 'rss/2.0'
require 'rss/maker'
require 'rss/content'

## Ugly hack to get content stuff with RSS 2.0
module RSS
  class RDF
    class Item; include ContentModel; end
  end
end 

@ann = YAML::load_file("announcements.txt")
@conf = YAML::load_file("lectures.txt")

rss = RSS::Maker.make("2.0") do |maker|
    maker.channel.title = "#{@conf["CLASS_SHORT"]} Announcements"
    maker.channel.description = "Announcements feed for the #{@conf["CLASS"]} course"
    maker.channel.link = @conf["COURSE_URL"]
    maker.encoding = "UTF-8"
    
    @ann.each { |a|
        item = maker.items.new_item
        item.link = "#{@conf["COURSE_URL"]}/announcements.html"
        item.title = a["T"]
        item.date = Time.parse(a["D"])
        item.description = a["C"]
    }
    maker.items.do_sort = true
    maker.items.max_size = 100
end

File.open("rss2.xml", "w+") do |f|
    f.print rss
end
