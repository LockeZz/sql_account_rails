module SqlAccount
  class TransactionAllowDate < Record 
    
    self.table_name = "sy_allowdate"
    self.primary_key = 'autokey'

    scope :global,      -> { where(context: nil) }
    scope :for_context, ->(ctx) { where(context: ctx) }
    scope :covering,    ->(date) { where('datefrom <= ? AND dateto >= ?', date, date) }
    scope :current,     -> { covering(Date.today) }

    def self.active
      current.global.first
    end

    # Is a transaction dated `date` allowed?
    # If no range is configured at all there is no restriction.
    def self.allowed?(date, context: nil)
      ranges = context ? for_context(context) : global
      return true unless ranges.exists?

      ranges.covering(date).exists?
    end


    # columns:
    # autokey   - Primary Key
    # datefrom  - Allowed date from
    # dateto    - Allowed date to
    # context   - Module context (nil = global, applies to all modules)
    # rowver    - Row Version (optimistic locking)

  end
end
