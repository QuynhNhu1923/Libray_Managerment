Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = "Settings"

  # Define ENV variable prefix used to load ENV variables into config
  config.env_prefix = 'SETTINGS'
end
