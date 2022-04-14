module SpreeBogo
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_bogo'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_bogo.environment', before: :load_config_initializers do |_app|
      SpreeBogo::Config = SpreeBogo::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    config.after_initialize do
      config = Rails.application.config
      config.spree.promotions.actions << ::Spree::Promotion::Actions::BuyXGetY
      config.spree.calculators.promotion_actions_create_adjustments << ::Spree::Calculator::BogoLineItemAdjustment
    end
  end
end
