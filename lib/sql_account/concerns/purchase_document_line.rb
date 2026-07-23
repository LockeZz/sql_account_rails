module SqlAccount
  module PurchaseDocumentLine
    extend ActiveSupport::Concern

    included do 
      belongs_to :stock_item,
        class_name: 'SqlAccount::StockItem',
        foreign_key: 'itemcode',
        primary_key: 'code',
        optional: true

      belongs_to :project,
        class_name: 'SqlAccount::Project',
        foreign_key: 'project',
        primary_key: 'code',
        optional: true

      scope :for_item, -> (code) { where(itemcode: code) }
      scope :for_location, -> (loc) { where(location: loc) }
      scope :for_batch, -> (b) { where(batch: b) }
      scope :for_project, -> (proj) { where(project: proj) }
      scope :printable, -> { where(printable: true) }
      scope :transferable, -> { where(transferable: true) }
      scope :with_tax, -> { where.not(tax: ['', nil]) }
      scope :from_doc, -> (type, key) { where(fromdoctype: type, fromdockey: key) }

      default_scope { select(column_names - %w[description3]) }
    end

    FROMDOC_MAP = {
      'PQ' => 'SqlAccount::PurchaseRequest',
      'PO' => 'SqlAccount::PurchaseOrder',
      'GR' => 'SqlAccount::GoodsReceived',
      'PI' => 'SqlAccount::PurchaseInvoice',
      'CP' => 'SqlAccount::CashPurchase',
      'SC' => 'SqlAccount::PurchaseReturn',
      'SD' => 'SqlAccount::DebitNote',
      'PC' => 'SqlAccount::PurchaseCreditNote',
      'EG' => 'SqlAccount::PurchaseExtraGoods',
    }.freeze


    def has_tax?
      tax.present?
    end

    def tax_inclusive?
      tax_inclusive == true
    end

    def transferable? 
      respond_to?(:transferable) && transferable == true 
    end

    def has_source_doc?
      respond_to?(:fromdoctype) && fromdoctype.present?
    end

    def amount_with_tax
      (amount || 0) + (taxamt || 0)
    end

    def source_document
      return nil unless respond_to?(:fromdoctype) && fromdoctype.present?
      
      klass = FROMDOC_MAP[fromdoctype.strip]
      return nil unless klass

      klass.constantize.find_by(dockey: fromdockey)
    end

    def source_line 
      return nil unless respond_to?(:fromdtlkey) && fromdtlkey.present?
      
      klass = FROMDOC_MAP[fromdoctype&.strip]
      return nil unless klass

      line_class = "#{klass}Line".constantize
      line_class.find_by(dtlkey: fromdtlkey)

    rescue NameError
      nil
    end

  end
end