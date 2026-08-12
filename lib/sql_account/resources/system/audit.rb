module SqlAccount
  class Audit < Record 

    self.table_name = "audt"
    self.primary_key = "dockey"

    has_many :details,
      class_name: 'SqlAccount::AuditDtl',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    
    scope :inserts,    -> { where("TRIM(updatekind) = 'I'") }
    scope :updates,    -> { where("TRIM(updatekind) = 'U'") }
    scope :deletes,    -> { where("TRIM(updatekind) = 'D'") }
    scope :active,     -> { where(deleted: false) }
    scope :for_module, ->(mod)  { where(module: mod) }
    scope :by_user,    ->(user) { where(username: user) }
    scope :recent,     -> { order(docdatetime: :desc) }
    scope :between,    ->(from, to) { where(docdatetime: from..to) }

    # Update kind constants
    INSERT = 'I'.freeze
    UPDATE = 'U'.freeze
    DELETE = 'D'.freeze

    # Module constants
    MODULE_GL = 'GL'.freeze
    MODULE_AR = 'AR'.freeze
    MODULE_AP = 'AP'.freeze  # purchasing
    MODULE_SL = 'SL'.freeze  # sales
    MODULE_PH = 'PH'.freeze  # purchase
    MODULE_ST = 'ST'.freeze  # stock


    def insert? 
      updatekind.strip == INSERT
    end

    def update? 
      updatekind.strip == UPDATE
    end

    def delete? 
      updatekind.strip == DELETE
    end

    def ref_table
      ref&.split(',')&.first&.strip
    end

    def ref_dockey
      ref&.split(',')&.last&.strip&.to_i
    end

    # columns:
    # dockey       - Primary Key
    # username     - SQL Account username who made the change
    # updatekind   - I = Insert, U = Update, D = Delete (padded with spaces)
    # module       - Module: GL/AR/AP/SL/PH/ST etc.
    # docdatetime  - Timestamp of the change
    # ref          - "TABLENAME, dockey" of the affected record
    # reference    - Human-readable description of the change
    #                e.g. "Invoice:TEST, Code: 300-10001, Date: 01/09/2025, Amount: 1060"
    # deleted      - Soft delete flag (boolean)

  end
end