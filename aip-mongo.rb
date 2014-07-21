#!/usr/bin/env ruby
require 'crack'
require 'open-uri'
require 'mongo'

db = Mongo::Connection.new.db('test')
aip = db.collection('aip')
xml = open("aip.xml").read
json = Crack::XML.parse(xml)
aip.save(json['mets'])
puts aip.find_one
