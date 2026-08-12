module SqlAccount 
  class AuditDtl < Record 

    self.table_name = "auditdtl"
    self.primary_key = "autokey"

    belongs_to :audit,
      class_name: 'SqlAccount::Audit',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    scope :for_table, -> (t) { where(tablename: t) }
    scope :for_field, -> (f) { where(fieldname: f) }
    scope :inserts, -> { where("TRIM(updatekind) = 'I") }
    scope :updates, -> { where("TRIM(updatekind) = 'U") }
    scope :deletes, -> { where("TRIM(updatekind) = 'D") }
    scope :changed, -> { where("old <> new") }

    def insert?
      updatekind.strip == 'I'
    end

    def update?
      updatekind.strip == 'U'
    end

    def delete?
      updatekind.strip == 'D'
    end

    def value_changed?
      old != self.new
    end

    # columns:
    # autokey      - Primary Key
    # dockey       - FK → audit.dockey
    # id           - Source table identifier (e.g. 'AR_IV')
    # tablename    - Actual table name affected (e.g. 'AR_IV')
    # fieldname    - Column that changed (e.g. 'DOCNO', 'CODE', 'DOCDATE')
    # old          - Previous value (empty string on Insert)
    # new          - New value (empty string on Delete)
    # updatekind   - I = Insert, U = Update, D = Delete (padded with spaces)
  end
end