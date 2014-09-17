require 'rubygems'
require 'bundler'
Bundler.setup

require './app.rb'

set :env, :production

run Sinatra::Application
