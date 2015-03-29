require 'rubygems'
require 'watir-webdriver'
require 'cgi'
require 'net/http'
require 'logger'
require 'nokogiri'

Dir["#{File.expand_path(File.dirname(__FILE__))}/linkedin-scraper/*.rb"].each { |file| require file }
