module SqlAccount
  module PurchaseDocumentLine
    extend ActiveSupport::Concern

    included do 
      belongs_to :stock_item,
        class_name: 'SqlAccount::StockItem',
        foreign_key: 'itemcode',
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

  end
end