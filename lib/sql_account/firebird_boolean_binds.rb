require 'delegate'

module SqlAccount
  # Fixing for firebird adapter peform_query where the adapter converts every bind value to a String before handing
  # it to the fb driver. i.e. `false`` become "false". The fb driver fills a BOOLEAN paramter from Ruby
  # object's truthiness (fb.c: `*(bool *)sqldata = obj`),
  # and any String is truthy, so every bound boolean became TRUE:
  #   where(cancelled: false)  matched the cancelled rows
  #   update(flag: false)      stored TRUE

  # Solutions: remember which bind positions held real true/false, let the adapter run
  # unchanged, and put the real booleans back just before the driver executes.
  # Nothing else about the query changes. Harmless if the adapter is fixed later.

  module FirebirdBooleanBinds
    class BindRestorer < SimpleDelegator

      def initialize(raw_connection, booleans)
        super(raw_connection)
        @booleans = booleans
      end

      def execute(sql, *args)
        @booleans.each { |index, value| args[index] = value if index < args.size }
        __getobj__.execute(sql, *args)
      end
    end

    private

    def perform_query(raw_connection, sql, binds, type_casted_binds, **kwargs)
      booleans = []
      type_casted_binds.each_with_index do |value, index|
        booleans << [index, value] if value == true || value == false
      end
      raw_connection = BindRestorer.new(raw_connection, booleans) unless booleans.empty?
      super(raw_connection, sql, binds, type_casted_binds, **kwargs)
    end

  end

end

ActiveSupport.on_load(:active_record) do
  require 'active_record/connection_adapters/firebird_adapter'
  ActiveRecord::ConnectionAdapters::FirebirdAdapter.prepend(SqlAccount::FirebirdBooleanBinds)
end