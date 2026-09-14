module SqlAccount
  class Project < Record

    self.table_name = "project"
    self.primary_key = "code"

    scope :active, -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: false)}
    scope :real, -> {where.not(code: '----')}

    default_scope { select(column_names - %w[attachments]) }

    has_many :customer_payments,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'project',
      primary_key: 'code'

    has_many :fa_item_projects,
      class_name: 'SqlAccount::FaItemProject',
      foreign_key: 'project',
      primary_key: 'code'
 
    has_many :fa_di_projects,
      class_name: 'SqlAccount::FaDiProject',
      foreign_key: 'project',
      primary_key: 'code'

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

