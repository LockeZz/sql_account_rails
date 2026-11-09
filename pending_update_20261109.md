# sql_account gem: deferred items

Things we decided to skip or park while auditing the gem. Revisit when needed.
Last updated: 2026-11-09.

## Done so far (for reference)

| Step | What |
|---|---|
| 1 | `with_reconnect` / `connection_lost?` (SQL errors no longer trigger reconnect), `alive?` typo, `port` in config |
| 2 | `default_scope select(...)` replaced by `ignored_columns` in 18 models (fixes `.count`) |
| 3 | `class_name` fixes for goods received / debit note, `FROMDOC_MAP` |
| 4, 4b, 4c | Supplier knockoff model + guard, customer knockoff guard, `CustomerInvoice` (`ar_iv`), sales invoice knockoffs/payments/outstanding |
| 5 | Purchase document typos (`cancelled?`, `multi_currency?`, `transferable?`) |
| 6 | Allowed-date validation (`TransactionAllowDate`, `DateValidation`) |
| 7 | `has_project?` fixes |
| 10 | FIFO model require, `tax_inclusive?`, sales line `fromdoctype` |
| 11 | Reverse traceability: `PurchaseRequest#purchase_orders`, `PurchaseOrder#goods_received_notes`, `PurchaseGoodsReceived#purchase_invoices` |

---

## 1. Step 8: remove the audit callbacks (IMPORTANT)

**Problem:** the purchasing and sales document concerns include `SqlAccount::Auditable`, whose callbacks call
`SqlAccount::AuditLogger`, a class that does not exist. Any create, update or destroy of a purchasing or
sales document through the gem raises `NameError`. Reads work fine.

**Why we parked it:** the Rails app already writes its own audit rows, so the gem should not.

**Edits when you come back to it:**
- Delete the `require` line for `auditable` in `lib/sql_account.rb`.
- Delete `lib/sql_account/concerns/auditable.rb`.
- Remove `include SqlAccount::Auditable` and `self.sql_account_module = ...` from
  `concerns/purchase_document.rb` and `concerns/sales_document.rb`.
- Remove the two commented-out audit lines in `purchase_order.rb`.

**Optional check:** compare `GEN_ID(AUDIT, 0)` with `MAX(dockey)` on the `audit` table, to see how the app assigns audit keys.
SQL Account's audit tables are `audit` / `auditdtl`, with Firebird generators `AUDIT` / `AUDITDTL`.

**Also look at:** how `create_po_job.rb` in the Rails app creates documents today (and why it does not hit this error).

---

## 2. Step 9: install generator (parked, app already works)

A fixed `install_generator.rb` exists (class `InstallGenerator`, writes `config/initializers/sql_account.rb`).
The initializer template (`sql_account_initializer.rb`) was also drafted.
Only matters for future apps; the existing app is already configured.
Do not apply unless you set up a new app. Check for a stray `config/initializer/` (singular) folder.

---

## 3. FIFO costing (unverified, do not use)

- `st_tr_fifo` has cost types `B`, `D`, `T`, `U` (CHAR, space-padded). There are **no** `'I'` or `'O'` rows.
- Each stock transaction writes 4 rows. Working theory (unconfirmed): `T` = movement, `B` = layer balance,
  `D` = value change, `U` = running total (qty and value).
- The latest `U` row matched `st_item.balsqty` (9 units / 629.55) but the "latest B per costseq" total did not (109 units).
- `costseq` seems to run higher = older, opposite to the model comment.
- The FIFO data in the live company file is known to be recorded unreliably.
- Current state: `fifo_cost`, `fifo_cost_layers`, `fifo_stock_value` return `nil`, `[]`, `0`.
- Suggested edit (not yet applied): replace the "Cost types observed: 'I' / 'O'" comment in
  `stock_transaction_fifo.rb` with an "UNVERIFIED, not reliable" warning.
- If FIFO is ever needed: use the latest `U` row for quantity and value, and look at `seq`, `costseq` and `st_tr` doctype
  with the full history of an item before trusting any layer logic. Use `balsqty` or WMA meanwhile.

---

## 4. Step 12 cleanup list

- `purchase_invoice.rb`: duplicated pieces (its own `belongs_to :supplier`, validations, scopes already in the shared
  concern). Check `irbm_validated_utc` vs `eiv_validated_utc` before removing.
- `Rails.logger` calls that should be safe logging (work without Rails): `stock_assembly`, `stock_adjustment`,
  `purchase_invoice`, `sales_document`, `purchase_document`, `date_validation`.
- `gemspec`: replace the TODO placeholders (summary, homepage, etc.).
- `README`: replace the template text.
- Failing placeholder spec: replace or remove.
- `sql_acc_db_schema.xlsx` is tracked in git: decide whether it belongs in the repo.
- `ph_pc` naming: the table is "Supplier Purchase Cancelled Note" (`SY_DOCNO` PC), but the model is called
  `PurchaseCreditNote`. `ph_sc` is the real Supplier Credit Note. There is no `ap_pc` table.
- `purchase_order_line.rb`: check the `udf_account` association; `purchase_document_line.rb` has a
  `belongs_to :gl_acount` (typo in the association name, left as is to avoid breaking callers).

---

## 5. Security

- **Rotate the SYSDBA password.** It is written in `db.md`. Remove it from the repo and from git history if it was committed.

---

## 6. Decisions to remember (not todo items)

- **No rename of `project` / journal associations.** `belongs_to :project` shadows the `project` column, but the app's
  `create_po_job.rb` (lines 22 and 58) passes `project:` objects, so renaming would break the app. `has_project?`
  was fixed with `self[:project]` instead.
- **Audit logging belongs to the Rails app**, not the gem.
- **Never compute `MAX+1` keys** on the live company file; use the Firebird generators.
- **Firebird CHAR padding:** use `TRIM` when comparing; costtype and doctype values come back padded.
- **Key spaces:** AP/AR knockoffs point at the ledger tables (`ap_pi.dockey`, `ar_iv.dockey`), not at `ph_pi` / `sl_iv`;
  documents link to ledger rows by `docno` + `code`. Purchase traceability (`PQ -> PO -> GR -> PI`) uses the document key space.
  `ph_sc` / `ph_sd` are empty in this database, so their links are unverified.
- **Allowed dates:** `sy_allowdate` currently covers 2025-07-01 to 2026-06-30, so today's date is outside it.
  New documents dated today fail the gem's date validation unless the range is extended in SQL Account or
  `validate_allowed_dates` is set to `false`.

---

## 7. Open question

- "PO doesn't show up in the software": investigate how documents created through the gem relate to what SQL Account
  displays (look at `create_po_job.rb`).