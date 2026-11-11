module SqlAccount
  class SupplierInvoice < Record 

    self.table_name = "ap_pi"
    self.primary_key = 'dockey'
    self.ignored_columns = %w[attachments]

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code',
      optional: true

    has_many :lines, -> { order(:seq) },
      class_name: 'SqlAccount::SupplierInvoiceLine',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    has_many :knockoffs, -> { where(todoctype: 'PI') },
      class_name: 'SqlAccount::SupplierKnockoff',
      foreign_key: 'todockey',
      primary_key: 'dockey'

    scope :not_cancelled, -> { where(cancelled: false) }
    scope :from_purchase, -> { where(fromdoctype: 'PI') }
    scope :ap_only, -> { where(fromdoctype: nil) }
    scope :outstanding, -> { where('ap_pi.docamt <> ap_pi.paymentamt') }

    def readonly?
      true 
    end

    def cancelled?
      cancelled == true
    end

    def from_purchase?
      fromdoctype.to_s.strip == 'PI'
    end

    def purchase_invoice
      return unless from_purchase?

      SqlAccount::PurchaseInvoice.find_by(docno: docno, code: code)
    end

    def payment_knockoffs
      knockoffs.where(fromdoctype: 'SP')
    end

    def payment_vouchers
      SqlAccount::CashBookEntry.payment_vouchers.where(fromdoctype: 'SP').where(
        "gl_cb.docno IN (SELECT s.docno FROM ap_sp s WHERE s.dockey IN (#{payment_knockoffs.select(:fromdockey).to_sql}))"      
      )
    end

    # SQL Account's own settled total: payments + credit notes + contras
    # (verified equal to the sum of knockoffs.koamt)
    def paid_amount
      paymentamt.to_d
    end

    def outstanding_amount
      docamt.to_d - paymentamt.to_d
    end

    def fully_settled?
      outstanding_amount.zero?
    end

  end
end