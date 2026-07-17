module SqlAccount
  class StockItemBatch < Record
    self.table_name = 'st_item_batch'
    self.primary_key = 'autokey'

    belongs_to :stock_batch,
      class_name: 'SqlAccount::StockBatch',
      foreign_key: 'parentkey',
      primary_key: 'autokey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    # validations
    validates :itemcode, presence: true

    # scopes
    scope :for_item, ->(code) { where(itemcode: code) }

    # columns:
    # autokey   - Primary Key
    # parentkey - FK to st_batch.autokey
    # itemcode  - Product Code (FK to st_item.code)
    #
    # NOTE: this is the detail table of ST_BATCH (batch master),
    # listing which stock items belong to a given batch.
    # It is NOT a standalone batch tracking table for individual items.
    # For batch-level stock balances, use ST_TR filtered by batch column.
  end
end