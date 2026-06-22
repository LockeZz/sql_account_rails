module SqlAccount
  module Generators
    class InstallGenerators < Rails::Generators::Base

      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'sql_account_initializer.rb', 'config/initializer/sql_account.rb'
      end

    end
  end
end