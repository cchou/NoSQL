#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'data_mapper' 
require './AIPInPremis'
require 'daitss/model/comment'
require 'daitss/model/agent'
require 'daitss/model/account'
require 'daitss/model/eggheadkey'
require 'daitss/model/package'
require 'daitss/model/aip'
require 'daitss/model/event'
require 'daitss/model/project'
require 'daitss/model/request'
require 'daitss/model/sip'
require 'crack'
require 'open-uri'
require 'mongo'

include Daitss

aip_descriptor = ARGV.shift or raise "aip descriptor required"

io = open(aip_descriptor)
doc = XML::Document.io(io)

adapter = DataMapper.setup :default, "postgres://daitss2:daitss2@localhost/daitss_db"
adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule
DataMapper.finalize
DataMapper::Model.raise_on_save_failure = true

begin
  #puts "validating AIP descriptor"
  #results = validate_xml aip_descriptor
  db = Mongo::Connection.new.db('test')
  aip = db.collection('aip')

  puts "parsing AIP descriptor"
  aipInPremis = AIPInPremis.new
  # aip = Aip.new :package => p, :copy => Copy.new

  # parse the aip descriptor and build the preservation records
  aipInPremis.process(nil, doc)
  require 'debugger'
  debugger
  json = aipInPremis.toJsonAll

  aip.save(json)
  # puts aip.find_one
  aip.find({"id"=>"info:fda/E70ZXZJEL_FNZBHA"}).each { |r| puts r["title"]}
  #xml = open("aip.xml").read
  #json = Crack::XML.parse(xml)

rescue => e
  puts "Caught exception #{e.class}: '#{e.message}' "
  e.backtrace.each { |line| puts line}        
  raise "cannot save aip"
end
