require 'rubygems'
require 'watir-webdriver'
require 'cgi'
require 'net/http'
require 'logger'
require 'mechanize'
require 'nokogiri'
require 'uri'
require 'json'

Dir["#{File.expand_path(File.dirname(__FILE__))}/linkedin-scraper/*.rb"].each { |file| require file }
