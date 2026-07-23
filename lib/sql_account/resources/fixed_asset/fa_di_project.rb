module SqlAccount
  class FaDiProject < Record
    self.table_name = 'fa_di_project'
    self.primary_key = 'autokey'

    belongs_to :project,
      class_name: 'SqlAccount::Project',
      foreign_key: 'project',
      primary_key: 'code'

    # belongs_to :fa_disposal_item — to be wired once FA module is modeled
    # parentkey references fa_di (Fixed Asset Disposal) detail line

    # columns:
    # autokey   - Primary Key
    # parentkey - FK to fa_di detail line (Fixed Asset Disposal)
    # project   - FK to project.code
    # rate      - Allocation Rate
    # cost      - Cost allocated to this project
    # qty       - Quantity
    # accumdepr - Accumulated Depreciation allocated to this project
    # netbook   - Net Book Value allocated to this project
    # amount    - Amount
    # gainloss  - Gain/Loss on disposal allocated to this project
    # rowver    - Row Version (optimistic locking)
    #
    # NOTE: table is empty in TESTING.FDB — part of Fixed Assets module
  end
end