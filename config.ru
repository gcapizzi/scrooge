require 'rubygems'
require 'bundler/setup'
require 'sprockets'

require './app/app'

map '/assets' do
  environment = Sprockets::Environment.new

  environment.append_path 'app/assets/javascripts'
  environment.append_path 'app/assets/stylesheets'

  foundation_dir = Gem::Specification.find_by_name('zurb-foundation').gem_dir
  environment.append_path "#{foundation_dir}/scss"
  environment.append_path "#{foundation_dir}/js"

  run environment
end

map '/' do
  run Scrooge::App
end
