#!/usr/bin/env ruby

if ARGV.size < 2
  puts "Usage: #{$0} <from version tag> <to version tag> [--no-dry-run]"
  puts "     : if --no-dry-run is specified, it will create a release on GitHub"
  exit 1
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "octokit"
  gem "faraday-retry"
  gem "nokogiri"
end

require "open-uri"

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_TOKEN']
  c.auto_paginate = true
  c.per_page = 100
end

client = Octokit::Client.new

note =  "## What's Changed\n\n"

notes = []

diff = client.compare("ruby/ruby", ARGV[0], ARGV[1])
diff[:commits].each do |c|
  if c[:commit][:message] =~ /\[(Backport|Feature|Bug) #(\d*)\]/
    url = "https://bugs.ruby-lang.org/issues/#{$2}"
    title = Nokogiri::HTML(URI.open(url)).title
    title.gsub!(/ - Ruby master - Ruby Issue Tracking System/, "")
  elsif c[:commit][:message] =~ /\(#(\d*)\)/
    url = "https://github.com/ruby/ruby/pull/#{$1}"
    title = Nokogiri::HTML(URI.open(url)).title
    title.gsub!(/ · ruby\/ruby · GitHub/, "")
  else
    next
  end
  notes << "* [#{title}](#{url})"
rescue OpenURI::HTTPError
  puts "Error: #{url}"
end

notes.uniq!

note << notes.join("\n")

note << "\n"
note << "Note: This list is automatically generated by tool/gen-github-release.rb. Because of this, some commits may be missing.\n\n"
note << "## Full Changelog\n\n"
note << "https://github.com/ruby/ruby/compare/#{ARGV[0]}...#{ARGV[1]}\n\n"

if ARGV[2] == "--no-dry-run"
  name = ARGV[1].gsub(/v/, "").gsub(/_/, ".")
  client.create_release("ruby/ruby", ARGV[1], name: name, body: note)
  puts "Created a release: https://github.com/ruby/ruby/releases/tag/#{ARGV[1]}"
else
  puts note
end