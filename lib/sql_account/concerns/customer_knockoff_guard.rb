module SqlAccount
  module CustomerKnockoffGuard
    extend ActiveSupport::Concern

    LEDGER_TABLES = { 'IV' => 'ar_iv' }.freeze

    included do 
      class_attribute :knockoff_doctype, instance_writer: false

      before_destroy :check_not_knocked_off, prepend: true 
    end


    # dockey(s) of this document's AR ledger record(s)
    def ledger_dockeys
      table = LEDGER_TABLES[knockoff_doctype]
      if table.nil?
        raise NotImplementedError, "#{self.class.name}: unsupported knockoff_doctype #{knockoff_doctype.inspect}"
      end

      conn = SqlAccount::Record.connection
      conn.execute(
        "SELECT dockey FROM #{table} WHERE docno = #{conn.quote(docno)} AND code = #{conn.quote(code)}"
      ).map(&:first)
    end

    def knocked_off?
      knocked_off_via?(ledger_dockeys)
    end


    private

    def knocked_off_via?(ledger_keys)
      ledger_keys.any? do |key|
        SqlAccount::CustomerKnockoff.where(
          '(fromdoctype = ? AND fromdockey = ?) OR (todoctype = ? AND todockey = ?)',
          knockoff_doctype, key, knockoff_doctype, key
        ).exists?
      end
    end

    def check_not_knocked_off
      keys = ledger_dockeys

      if keys.empty?
        errors.add(:base, "Cannot delete #{self.class.name.demodulize} '#{docno}' - its AR ledger record was not found, so knock-off status cannot be verified")
        throw(:abort)
      end

      return unless knocked_off_via?(keys)

      errors.add(:base, "Cannot delete #{self.class.name.demodulize} '#{docno}' - it has been knocked off by a payment or credit note")
      throw(:abort)
    end


  end
end