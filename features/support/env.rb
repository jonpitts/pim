#require 'rubygems'
#require 'bundler'
#Bundler.setup
require 'mock_server'

# setup the app
#app_file = File.join(File.dirname(__FILE__), '../../app.rb')
#require app_file

app_file = File.join(File.dirname(__FILE__), *%w[.. .. app.rb])
require app_file
Sinatra::Application.app_file = app_file

require 'rspec/expectations'
require 'rspec/collection_matchers'
require 'rack/test'
require 'webrat'

$:.unshift File.join(File.dirname(__FILE__), '../../lib')
require 'validation'

Webrat.configure do |config|
  config.mode = :rack
end

#Sinatra::Application.set :environment, :test

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  
  Webrat::Methods.delegate_to_session :response_code, :response_body
  
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


end

World{MyWorld.new}
include MockServer::Methods

mock_server do

  get "/wip.png" do
    f = File.join File.dirname(__FILE__), '..', 'fixtures', "wip.png"
    send_file f, :type => 'image/png'
  end

end
