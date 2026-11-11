module SqlAccount
  class SupplierPayment < Record 

    self.table_name = "ap_sp"
    self.primary_key = "dockey"
    self.ignored_columns = %w[attachments]

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code',
      optional: true 
    
    has_many :knockoffs, -> { where(fromdoctype: 'SP') },
      class_name: 'SqlAccount::SupplierKnockoff',
      foreign_key: 'fromdockey',
      primary_key: 'dockey'

    scope :not_cancelled, -> { where(cancelled: false) }
    scope :unapplied, -> { where('ap_sp.unappliedamt <> 0') }


    def readonly?
      true
    end

    def cancelled?
      cancelled == true
    end

    # The Cash Book PV row for this payment
    def payment_voucher
      SqlAccount::CashBookEntry.payment_vouchers.find_by(docno: docno, fromdoctype: 'SP')
    end

    # Supplier invoices this payment was knocked off against (covers A/P-only invoices too)
    def supplier_invoices
      SqlAccount::SupplierInvoice.where(dockey: knockoffs.where(todoctype: 'PI').select(:todockey))
    end

    def applied_amount
      knockoffs.sum(:koamt)
    end

    def unapplied_amount
      unappliedamt.to_d
    end

    # :unapplied         - not knocked off against anything yet (paid before invoice, or rejected)
    # :partially_applied - knocked off, but some money is still unapplied
    # :fully_applied     - all of it knocked off
    def application_status
      return :unapplied unless knockoffs.exists?
      unapplied_amount.zero? ? :fully_applied : :partially_applied
    end
    
  end
end