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
    
    scope :ready_to_order, -> { where(transferable: true, cancelled: false) }
    scope :transferred, -> { where(transferable: false, cancelled: false) }

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

    def ready_to_order? 
      transferable == true && !cancelled?
    end

  end
end


  # dockey: 14,
  # docno: "PQ-00004",
  # docnoex: nil,
  # docdate: "2026-07-21",
  # postdate: "2026-07-21",
  # taxdate: "2026-07-21",
  # code: "",
  # companyname: "REQUEST BY YAP",
  # address1: nil,
  # address2: nil,
  # address3: nil,
  # address4: nil,
  # postcode: nil,
  # city: nil,
  # state: nil,
  # country: nil,
  # phone1: nil,
  # mobile: nil,
  # fax1: nil,
  # attention: nil,
  # area: "----",
  # agent: "----",
  # project: "----",
  # terms: nil,
  # currencycode: "----",
  # currencyrate: 0.1e1,
  # shipper: "----",
  # description: "Purchase Request",
  # cancelled: false,
  # status: 0,
  # docamt: 0.0,
  # localdocamt: 0.0,
  # validity: nil,
  # deliveryterm: nil,
  # cc: nil,
  # docref1: nil,
  # docref2: nil,
  # docref3: nil,
  # docref4: nil,
  # branchname: nil,
  # daddress1: "1, Jalan Setia Dagang AK U13/AK,",
  # daddress2: "Setia Alam, 40170,",
  # daddress3: "Shah Alam, Selangor.",
  # daddress4: nil,
  # dpostcode: "40170",
  # dcity: "Shah Alam",
  # dstate: "Selangor",
  # dcountry: "",
  # dattention: nil,
  # dphone1: "03-78901300",
  # dmobile: nil,
  # dfax1: nil,
  # taxexemptno: nil,
  # salestaxno: nil,
  # servicetaxno: nil,
  # tin: nil,
  # idtype: nil,
  # idno: nil,
  # tourismno: nil,
  # sic: nil,
  # incoterms: nil,
  # submissiontype: nil,
  # businessunit: nil,
  # transferable: true,
  # updatecount: nil,
  # printcount: 0,
  # lastmodified: 1782147992
