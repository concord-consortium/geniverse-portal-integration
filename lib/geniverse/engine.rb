module Geniverse
  class Engine < ::Rails::Engine
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
      end
    end
    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end
  end
end
