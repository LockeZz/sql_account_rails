module SqlAccount
  module SupplierKnockoffGuard 
    extend ActiveSupport::Concern

    # Purchase document types where the AP Ledger that ap_knockoff refers to
    LEDGER_TABLES = { 'PI' => 'ap_pi', 'SC' => 'ap_sc', 'SD' => 'ap_sd' }.freeze

    included do 
      class_attribute :knockoff_doctype, instance_writer: false

      # prepend: run before dependent: :destroy and before audit callbacks
      before_destroy :check_not_knocked_off, prepend: true
    end

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
        SqlAccount::SupplierKnockoff.involving(knockoff_doctype, key).exists?
      end
    end

    def check_not_knocked_off
      keys = ledger_dockeys

      if keys.empty?
        errors.add(:base, "Cannot delete #{self.class.name.demodulize} '#{docno}' - its AP ledger record was not found, so knock-off status cannot be verified")
        throw(:abort)
      end

      return unless knocked_off_via?(keys)

      errors.add(:base, "Cannot delete #{self.class.name.demodulize} '#{docno}' - it has been knocked off by a payment or credit note")
      throw(:abort)
    end

  end
end