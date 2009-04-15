# Go to http://wiki.merbivore.com/pages/init-rb

#  use_orm :none
use_test :rspec
use_template_engine :erb

# Specify a specific version of a dependency
# dependency "RedCloth", "> 3.0"

Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end

# Move this to application.rb if you want it to be reloadable in dev mode.
Merb::Router.prepare do
  match('/').to(:controller => "merb_flat_spike", :action =>'index')

  default_routes
end

Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = :debug,
  c[:log_stream]          = STDOUT,
  # or use file for logging:
  # c[:log_file]          = Merb.root / "log" / "merb.log",
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_merb-flat-spike_session_id',
  c[:session_secret_key]  = 'fa590cdca202d65f24ac8a923c775dc1e9d4b075',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_templates]    = true,
  c[:reload_time]         = 0.5
}
