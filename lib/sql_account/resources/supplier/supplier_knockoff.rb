module SqlAccount
  class SupplierKnockoff < Record 

    self.table_name = 'ap_knockoff'

    scope :settled_by,    ->(doctype, dockey) { where(fromdoctype: doctype, fromdockey: dockey) }
    scope :settling,      ->(doctype, dockey) { where(todoctype: doctype, todockey: dockey) }
    scope :involving,     ->(doctype, dockey) {
      where('(fromdoctype = ? AND fromdockey = ?) OR (todoctype = ? AND todockey = ?)',
            doctype, dockey, doctype, dockey)
    }
    scope :with_gainloss, -> { where('gainloss <> 0') }

    def readonly?
      true
    end
  end
end