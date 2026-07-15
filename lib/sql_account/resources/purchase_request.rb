module SqlAccount
  class PurchaseRequest < Record

    self.table_name = 'ph_pq'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::PurchaseRequestLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # columns (header — shared with all PH_* docs):
    # dockey           - PK
    # docno            - Document No (business key)
    # docnoex          - External Document No
    # docdate          - Document Date
    # postdate         - Post Date
    # taxdate          - Tax Date
    # code             - Supplier Account Code (FK to ap_supplier.code)
    # companyname      - Supplier Name (denormalized)
    # address1-4       - Billing Address
    # postcode/city/state/country - Billing address components
    # phone1/mobile/fax1/attention - Contact (denormalized)
    # area/agent       - Area and Agent
    # project          - Project
    # terms            - Payment Terms
    # currencycode     - Currency ('----' = local)
    # currencyrate     - Exchange Rate
    # shipper          - Shipper
    # description      - Document Description
    # cancelled        - Cancelled flag (boolean)
    # status           - Status (integer)
    # docamt           - Document Total Amount
    # localdocamt      - Local Currency Total
    # validity         - Validity period
    # deliveryterm     - Delivery Terms
    # cc/docref1-4     - CC and References
    # branchname       - Branch Name
    # daddress1-4      - Delivery Address
    # transferable     - Transferable flag (boolean)
    # updatecount/printcount/lastmodified

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1 ))}
    end

  end
end