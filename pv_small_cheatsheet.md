```
# ── 1. A purchase invoice: who paid it, and how much each PV paid ─────────────
inv = SqlAccount::PurchaseInvoice.find_by(docno: 'INV:25/08/3605')
puts "== #{inv.docno} (#{inv.code})"
puts "docamt=#{inv.docamt.to_f} paid=#{inv.paid_amount.to_f} outstanding=#{inv.outstanding_amount.to_f}"
inv.payment_knockoffs.each do |k|
  pv_no = SqlAccount::Record.connection.execute("SELECT TRIM(docno) FROM ap_sp WHERE dockey = #{k.fromdockey.to_i}").first&.first
  puts "  #{pv_no}  paid #{k.koamt.to_f} on #{k.kotaxdate}"
end

# ── 2. An A/P-only invoice (no PurchaseInvoice exists) ───────────────────────
si = SqlAccount::SupplierInvoice.find_by(docno: 'INV:240807', code: '400-V0020')
puts "\n== #{si.docno} (A/P only, purchase_invoice=#{si.purchase_invoice.inspect})"
puts "PVs: #{si.payment_vouchers.pluck(:docno).map(&:strip).inspect}  settled?=#{si.fully_settled?}"
si.lines.each { |l| puts "  line: #{l.account} #{l.gl_account&.description.to_s[0, 40]}  #{l.amount.to_f}" }

# ── 3. A supplier: outstanding invoices + money paid but not yet knocked off ─
sup = SqlAccount::Supplier.find_by(code: '405-B0006')
open_inv = SqlAccount::SupplierInvoice.not_cancelled.outstanding.where(code: sup.code)
puts "\n== supplier #{sup.code}"
puts "outstanding invoices: #{open_inv.count}, total #{open_inv.to_a.sum(&:outstanding_amount).to_f}"
open_inv.order(docdate: :desc).limit(5).each { |i| puts "  #{i.docno.strip}  #{i.docdate}  owing #{i.outstanding_amount.to_f}" }
puts "unapplied PVs: #{sup.unapplied_payment_vouchers.pluck(:docno, :docamt).map { |d, a| [d.strip, a.to_f] }.inspect}"

# ── 4. Cash book: PVs paid straight to GL accounts (not supplier payments) ───
pv = SqlAccount::CashBookEntry.payment_vouchers.cash_book_only.not_cancelled.order(dockey: :desc).first
puts "\n== #{pv.docno.strip} #{pv.docdate}  #{pv.docamt.to_f}  from #{pv.payment_account&.description}"
pv.lines.each { |l| puts "  #{l.code} #{l.gl_account&.description.to_s[0, 40]}  #{l.amount.to_f}" }

# ── 5. Totals sanity check ───────────────────────────────────────────────────
CB = SqlAccount::CashBookEntry
puts "\nPV: #{CB.payment_vouchers.count} total = #{CB.payment_vouchers.cash_book_only.count} cash book + #{CB.payment_vouchers.from_payments.count} from payments/refunds"
puts "OR: #{CB.official_receipts.count} total = #{CB.official_receipts.cash_book_only.count} cash book + #{CB.official_receipts.from_payments.count} from payments/refunds"
puts "supplier invoices outstanding: #{SqlAccount::SupplierInvoice.not_cancelled.outstanding.count} of #{SqlAccount::SupplierInvoice.count}"
```