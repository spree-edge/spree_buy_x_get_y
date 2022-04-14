module SpreeBogo
  class Configuration < Spree::Preferences::Configuration
   preference :enabled, :boolean, default: true
  end
end
