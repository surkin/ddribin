#!/usr/bin/ruby -w

require "cgi"

cgi = CGI.new("html4")

start = `/Users/dave/work/ddribin/bouncer/build/Debug/bouncerStart`

cgi.out() do
  cgi.html() do
    cgi.head{ cgi.title{"Remote Start"} } +
    cgi.body() do
      cgi.p{ "Remote Start" } +
      cgi.pre { "#{start}" }
    end
  end
end
