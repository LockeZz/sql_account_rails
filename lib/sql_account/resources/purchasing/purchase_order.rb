module SqlAccount
  class PurchaseOrder < Record
    self.table_name = 'ph_po'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::PurchaseOrderLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # traceability — PO can originate from a Purchase Request
    scope :from_request, -> { joins(:lines).where("ph_podtl.fromdoctype = 'PQ'").distinct }

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # extra columns vs PQ (on top of shared header):
    # d_docno              - Payment Document No
    # d_paymentmethod      - Payment Method
    # d_chequenumber       - Cheque Number
    # d_paymentproject     - Payment Project
    # d_bankcharge         - Bank Charge
    # d_bankchargeaccount  - Bank Charge Account
    # d_amount             - Discount Amount
    # peppol_uuid          - Peppol UUID
  end
end
