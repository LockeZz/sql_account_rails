module SqlAccount
  class TransactionAllowDate < Record 
    
    self.table_name = "sy_allowdate"
    self.primary_key = 'autokey'

    scope :global, -> { where(context: nil)}
    scope :for_context, -> (ctx) { where(context: ctx) }
    scope :current, -> { where("dateform <= ? AND dateto >= ?", Date.today, Date.today)}

    def self.active
      current.global.first
    end

    # columns:
    # autokey   - Primary Key
    # datefrom  - Allowed date from
    # dateto    - Allowed date to
    # context   - Module context (nil = global, applies to all modules)
    # rowver    - Row Version (optimistic locking)

  end
end
