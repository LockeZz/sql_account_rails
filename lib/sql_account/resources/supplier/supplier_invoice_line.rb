module SqlAccount
  class SupplierInvoiceLine < Record

    self.table_name = "ap_pidtl"
    self.primary_key = "dtlkey"

    belongs_to :supplier_invoice,
      class_name: 'SqlAccount::SupplierInvoice',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      optional: true

    belongs_to :gl_account,
      class_name: 'SqlAccount::GlAccount',
      foreign_key: 'dockey',
      primary_key: 'code',
      optional: true 

    def readonly?
      true
    end

    def tax_inclusive?
      taxinclusive == true || taxinclusive.to_s == '1'
    end

  end
end