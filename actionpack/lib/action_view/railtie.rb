require "action_view"
require "rails"

module ActionView
  # = Action View Railtie
  class Railtie < Rails::Railtie
    config.action_view = ActiveSupport::OrderedOptions.new
    config.action_view.stylesheet_expansions = {}
    config.action_view.javascript_expansions = { :defaults => %w(jquery jquery_ujs) }

    initializer "action_view.logger" do
      ActiveSupport.on_load(:action_view) { self.logger ||= Rails.logger }
    end

    initializer "action_view.cache_asset_ids" do |app|
      unless app.config.cache_classes
        ActiveSupport.on_load(:action_view) do
          ActionView::Helpers::AssetTagHelper::AssetPaths.cache_asset_ids = false
        end
      end
    end

    initializer "action_view.javascript_expansions" do |app|
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
          app.config.action_view.delete(:javascript_expansions)
        )

        ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
          app.config.action_view.delete(:stylesheet_expansions)
        )
      end
    end

    initializer "action_view.set_configs" do |app|
      ActiveSupport.on_load(:action_view) do
        self.default_method_for_update = app.config.default_method_for_update
        app.config.action_view.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    initializer "action_view.caching" do |app|
      ActiveSupport.on_load(:action_view) do
        if app.config.action_view.cache_template_loading.nil?
          ActionView::Resolver.caching = app.config.cache_classes
        end
      end
    end
  end
end
