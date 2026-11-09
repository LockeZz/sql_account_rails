module SqlAccount
  class CashBookEntryLine < Record
    self.table_name  = 'gl_cbdtl'
    self.primary_key = 'dtlkey'

    belongs_to :cash_book_entry,
      class_name:  'SqlAccount::CashBookEntry',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      optional:    true

    belongs_to :gl_account,
      class_name:  'SqlAccount::GlAccount',
      foreign_key: 'code',
      primary_key: 'code',
      optional:    true

    def readonly?
      true
    end

    def tax_inclusive?
      taxinclusive == true || taxinclusive.to_s == '1'
    end
  end
end