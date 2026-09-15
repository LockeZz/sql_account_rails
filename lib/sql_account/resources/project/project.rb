module SqlAccount
  class Project < Record

    self.table_name = "project"
    self.primary_key = "code"

    has_many :purchase_requests,
      class_name: 'SqlAccount::PurchaseRequest',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_orders,
      class_name: 'SqlAccount::PurchaseOrder',
      foreign_key: 'project', primary_key: 'code'

    has_many :goods_receiveds,
      class_name: 'SqlAccount::PurchaseGoodsReceived',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_invoices,
      class_name: 'SqlAccount::PurchaseInvoice',
      foreign_key: 'project', primary_key: 'code'

    has_many :cash_purchases,
      class_name: 'SqlAccount::CashPurchase',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_returns,
      class_name: 'SqlAccount::PurchaseReturn',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_debit_notes,
      class_name: 'SqlAccount::PurchaseDebitNote',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_credit_notes,
      class_name: 'SqlAccount::PurchaseCreditNote',
      foreign_key: 'project', primary_key: 'code'

    has_many :purchase_extra_goods,
      class_name: 'SqlAccount::PurchaseExtraGoods',
      foreign_key: 'project', primary_key: 'code'

    has_many :customer_payments,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'project',
      primary_key: 'code'

    has_many :stock_transactions,
      class_name: 'SqlAccount::StockTransaction',
      foreign_key: 'project', primary_key: 'code'

    has_many :stock_adjustments,
      class_name: 'SqlAccount::StockAdjustment',
      foreign_key: 'project', primary_key: 'code'

    has_many :stock_assemblies,
      class_name: 'SqlAccount::StockAssembly',
      foreign_key: 'project', primary_key: 'code'

    has_many :fa_item_projects,
      class_name: 'SqlAccount::FaItemProject',
      foreign_key: 'project',
      primary_key: 'code'

    has_many :fa_di_projects,
      class_name: 'SqlAccount::FaDiProject',
      foreign_key: 'project',
      primary_key: 'code'

    # ── Scopes ────────────────────────────────────────────────────
    scope :active,   -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: false) }

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

