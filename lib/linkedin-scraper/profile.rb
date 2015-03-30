# -*- coding: utf-8 -*-
module Linkedin

  class Profile

    ATTRIBUTES = %w(
    name
    first_name
    last_name
    title
    location
    country
    industry
    summary
    picture
    linkedin_url
    education
    groups
    websites
    languages
    skills
    certifications
    organizations
    past_companies
    current_companies
    recommended_visitors)

    attr_reader :page, :linkedin_url, :browser

    def self.get_profile(url)
      Linkedin::Profile.new(url)
    rescue => e
      puts e
    end

    def initialize(browser, url)
      @linkedin_url = url
      browser.goto url
      @page         = Nokogiri::HTML(browser.html)
    end

    #Gets the profile of the authenticated user
    def self.me(browser)
      return Profile.new(browser, 'https://www.linkedin.com/profile/preview')
    end

    def name
      "#{first_name} #{last_name}"
    end

    def first_name
      @first_name ||= (@page.at('.full-name').text.split(' ', 2)[0].strip if @page.at('.full-name'))
    end

    def last_name
      @last_name ||= (@page.at('.full-name').text.split(' ', 2)[1].strip if @page.at('.full-name'))
    end

    def title
      @title ||= (@page.at('.title').text.gsub(/\s+/, ' ').strip if @page.at('.title'))
    end

    def location
      @location ||= (@page.at('.locality').text.split(',').first.strip if @page.at('.locality'))
    end

    def country
      @country ||= (@page.at('.locality').text.split(',').last.strip if @page.at('.locality'))
    end

    def industry
      @industry ||= (@page.at('.industry').text.gsub(/\s+/, ' ').strip if @page.at('.industry'))
    end

    def summary
      @summary ||= (@page.at('.summary .description').text.gsub(/\s+/, ' ').strip if @page.at('.summary .description'))
    end

    def picture
      @picture ||= (@page.at('.profile-picture img').attributes['src'].value.strip if @page.at('.profile-picture img'))
    end

    def skills
      @skills ||= (@page.search('.skill-pill .endorse-item-name-text').map { |skill| skill.text.strip if skill.text } rescue nil)
    end

    def past_companies
      @past_companies ||= get_companies('past')
    end

    def current_companies
      @current_companies ||= get_companies('current')
    end

    def education
      @education ||= @page.search('.background-education .education').map do |item|
        name   = item.at('h4').text.gsub(/\s+|\n/, ' ').strip      if item.at('h4')
        desc   = item.at('h5').text.gsub(/\s+|\n/, ' ').strip      if item.at('h5')
        period = item.at('.education-date').text.gsub(/\s+|\n/, ' ').strip if item.at('.education-date')

        {:name => name, :description => desc, :period => period }
      end
    end

    def websites
      @websites ||=  @page.search('#overview-summary-websites').flat_map do |site|
        url = "http://www.linkedin.com#{site.at('a')['href']}"
        CGI.parse(URI.parse(url).query)['url']
      end

    end

    def groups
      @groups ||= @page.search('.groups-name').map do |item|
        name = item.text.gsub(/\s+|\n/, ' ').strip
        link = "http://www.linkedin.com#{item.at('a')['href']}"
        { :name => name, :link => link }
      end
    end

    def organizations
      @organizations ||= @page.search('#background-organizations .section-item').map do |item|
        name       = item.at('.summary').text.gsub(/\s+|\n/, ' ').strip rescue nil
        start_date, end_date = item.at('.organizations-date').text.gsub(/\s+|\n/, ' ').strip.split(' – ') rescue nil
        start_date = Date.parse(start_date) rescue nil
        end_date   = Date.parse(end_date)   rescue nil
        { :name => name, :start_date => start_date, :end_date => end_date }
      end
    end

    def languages
      @languages ||= @page.search('.background-languages #languages ol li').map do |item|
        language    = item.at('h4').text rescue nil
        proficiency = item.at('div.languages-proficiency').text.gsub(/\s+|\n/, ' ').strip rescue nil
        { :language => language, :proficiency => proficiency }
      end
    end

    def certifications
      @certifications ||= @page.search('background-certifications').map do |item|
        name       = item.at('h4').text.gsub(/\s+|\n/, ' ').strip                         rescue nil
        authority  = item.at('h5').text.gsub(/\s+|\n/, ' ').strip            rescue nil
        license    = item.at('.specifics/.licence-number').text.gsub(/\s+|\n/, ' ').strip rescue nil
        start_date = item.at('.certification-date').text.gsub(/\s+|\n/, ' ').strip        rescue nil

        { :name => name, :authority => authority, :license => license, :start_date => start_date }
      end
    end


    def recommended_visitors
      @recommended_visitors ||= @page.search('.insights-browse-map/ul/li').map do |visitor|
        v = {}
        v[:link]    = visitor.at('a')['href']
        v[:name]    = visitor.at('h4/a').text
        v[:title]   = visitor.at('.browse-map-title').text.gsub('...', ' ').split(' at ').first
        v[:company] = visitor.at('.browse-map-title').text.gsub('...', ' ').split(' at ')[1]
        v
      end
    end

    def to_json
      require 'json'
      ATTRIBUTES.reduce({}){ |hash,attr| hash[attr.to_sym] = self.send(attr.to_sym);hash }.to_json
    end

    private

    def get_companies(type)
      companies = []
      if @page.search(".background-experience .#{type}-position").first
        @page.search(".background-experience .#{type}-position").each do |node|

          company               = {}
          company[:title]       = node.at('h4').text.gsub(/\s+|\n/, ' ').strip if node.at('h4')
          company[:company]     = node.at('h4').next.text.gsub(/\s+|\n/, ' ').strip if node.at('h4').next
          company[:description] = node.at(".description").text.gsub(/\s+|\n/, ' ').strip if node.at(".description")

          start_date, end_date  = node.at('.experience-date-locale').text.strip.split(" – ") rescue nil
          company[:start_date] = parse_date(start_date) rescue nil
          company[:end_date] = parse_date(end_date) rescue nil

          company_link = node.at('h4').next.at('a')['href'] if node.at('h4').next.at('a')
        end
      end
      companies
    end

    def parse_date(date)
      date = "#{date}-01-01" if date =~ /^(19|20)\d{2}$/
      Date.parse(date)
    end
  end
end
