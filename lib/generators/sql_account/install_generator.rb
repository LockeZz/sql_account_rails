require 'rails/generators/base'

module SqlAccount
  module Generators
    class InstallGenerators < Rails::Generators::Base

      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'sql_account_initializer.rb', 'config/initializer/sql_account.rb'
      end

      def show_readme
        say "\nSqlAccount installed! Edit config/initializer/sql_account.rb and set your ENV vars.", :green
      end

    end
  end
end