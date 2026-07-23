module SqlAccount
  class FaItemProject < Record
    self.table_name = 'fa_item_project'
    self.primary_key = 'autokey'

    belongs_to :project,
      class_name: 'SqlAccount::Project',
      foreign_key: 'project',
      primary_key: 'code'

    # belongs_to :fa_item — to be wired once FA module is modeled
    # code references fa_item (Fixed Asset Item)

    # columns:
    # autokey  - Primary Key
    # code     - FK to fa_item.code (Fixed Asset Item)
    # project  - FK to project.code
    # rate     - Allocation Rate for this project
    # cost     - Cost allocated to this project
    # qty      - Quantity
    # rowver   - Row Version (optimistic locking)
    #
    # NOTE: table is empty in TESTING.FDB — part of Fixed Assets module
  end
end