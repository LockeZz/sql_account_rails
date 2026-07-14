module SqlAccount
  class StockBatch < Record
    self.table_name = 'st_batch'
    self.primary_key = 'autokey'

    has_many :batch_items,
      class_name: 'SqlAccount::StockItemBatch',
      foreign_key: 'parentkey',
      primary_key: 'autokey',
      dependent: :destroy

    has_many :stock_items,
      through: :batch_items,
      class_name: 'SqlAccount::StockItem',
      source: :stock_item

    # validations
    validates :code, presence: true

    # scopes
    scope :active,   -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: false) }
    scope :expired,  -> { where("expdate < ?", Date.today) }
    scope :valid,    -> { where("expdate IS NULL OR expdate >= ?", Date.today) }

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[attachments]) }

    # Partial delete of a specific item from batch — mirrors SDK pattern
    # (uses Locate + Delete, not delete-all-reinsert)
    def remove_item(itemcode)
      batch_items.find_by(itemcode: itemcode)&.destroy
    end

    # columns:
    # (1 Unknown computed col)
    # autokey      - Primary Key
    # code         - Batch Code (business key, used for SDK lookup)
    # description  - Batch Description
    # expdate      - Expiry Date
    # mfgdate      - Manufacturing Date
    # remark1      - Remark 1
    # remark2      - Remark 2
    # isactive     - Active flag (boolean)
    # attachments  - Attachments (Binary/Blob)
    # rowver       - Row Version (optimistic locking)
  end
end