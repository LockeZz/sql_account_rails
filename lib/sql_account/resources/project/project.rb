module SqlAccount
  class Project < Record

    self.table_name = "project"
    self.primary_key = "code"

    scope :active, -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: false)}
    scope :real, -> {where.not(code: '----')}

    default_scope { select(column_names - %w[attachments]) }

    # columns:
    # (1 Unknown computed col)
    # code          - Project Code (PK, '----' = NON-PROJECT default)
    # description   - Project Description
    # description2  - Project Description 2
    # projectvalue  - Project Value (budgeted/contracted amount)
    # projectcost   - Project Cost (actual cost incurred)
    # attachments   - Attachments (Binary/Blob)
    # isactive      - Active flag (boolean)

  end
end

