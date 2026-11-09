require 'rails/generators/base'

module SqlAccount
  module Generators
    class InstallGenerators < Rails::Generators::Base

      source_root File.expand_path('templates', __dir__)

      desc 'Creates config/initializers/sql_account.rb for the SQL Account (Firebird) connection'

      def copy_initializer
        template 'sql_account_initializer.rb', 'config/initializer/sql_account.rb'
      end

      def show_readme
        say "\nSqlAccount installed! Edit config/initializers/sql_account.rb and set your ENV vars:", :green
        say '  SQL_ACCOUNT_HOST, SQL_ACCOUNT_PORT, SQL_ACCOUNT_DATABASE, SQL_ACCOUNT_USERNAME, SQL_ACCOUNT_PASSWORD'
        say "\nThe Firebird adapter is not a gemspec dependency. Add it to your Gemfile:", :green
        say "  gem 'firebird_adapter', github: 'LockeZz/firebird_adapter'"
      end

    end
  end
end