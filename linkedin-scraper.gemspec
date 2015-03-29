# -*- encoding: utf-8 -*-
require File.expand_path('../lib/linkedin-scraper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Yatish Mehta', 'Csongor Zalatnai']
  gem.description   = %q{Scrapes the linkedin profile when a url, username, and password is given }
  gem.summary       = %q{when a url of  linkedin profile page is given it scrapes the entire page and converts into a accessible object}
  gem.homepage      = 'https://github.com/zalatnaicsongor/linkedin-scraper'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['linkedin-scraper']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'linkedin-scraper'
  gem.require_paths = ['lib']
  gem.version       = Linkedin::Scraper::VERSION

  gem.add_dependency(%q<mechanize>, ['>= 0'])
  
  gem.add_development_dependency 'rspec', '>=0'
  gem.add_development_dependency 'rake'
  gem.add_dependency(%q<watir-webdriver>, ['>= 0'])

end
