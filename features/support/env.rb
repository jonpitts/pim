require 'rubygems'
require 'bundler'

require 'rspec'
require 'rack/test'
require 'webrat'
#require 'mock_server'

# setup the app
app_file = File.join(File.dirname(__FILE__), '../../app.rb')
require app_file

$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'validation'

Webrat.configure do |config|
  config.mode = :rack
end

Sinatra::Application.set :environment, :test

class MyWorld

  def app
    Sinatra::Application
  end

  def fixture_file name
    File.join(File.dirname(__FILE__), '..', 'fixtures', name)
  end

  def fixture_data name
    file = fixture_file name
    open(file) { |io| io.read }
  end

  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end

#include MockServer::Methods

#mock_server do

#  get "/wip.png" do
#    f = File.join File.dirname(__FILE__), '..', 'fixtures', "wip.png"
#    send_file f, :type => 'image/png'
#  end

#end

World do
    MyWorld.new
end

