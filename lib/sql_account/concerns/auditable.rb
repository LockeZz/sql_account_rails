module SqlAccount
  module Auditable
    extend ActiveSupport::Concern

    included do
      before_update  :capture_previous_changes
      after_create   :log_audit_insert
      after_update   :log_audit_update
      before_destroy :log_audit_delete

      # Set in each model — e.g:
      # class_attribute :sql_account_module, default: SqlAccount::Audit::MODULE_PH
      class_attribute :sql_account_module,   default: nil
      class_attribute :sql_account_username, default: 'RAILS'
    end

    private

    def capture_previous_changes
      @previous_changes_for_audit = changes.transform_values { |change| [change[0], change[1]] }
    end

    def log_audit_insert
      return unless sql_account_module
      SqlAccount::AuditLogger.log_insert(
        record:   self,
        module:   sql_account_module,
        username: sql_account_username
      )
    end

    def log_audit_update
      return unless sql_account_module
      return if @previous_changes_for_audit.blank?
      SqlAccount::AuditLogger.log_update(
        record:           self,
        module:           sql_account_module,
        username:         sql_account_username,
        previous_changes: @previous_changes_for_audit
      )
    end

    def log_audit_delete
      return unless sql_account_module
      SqlAccount::AuditLogger.log_delete(
        record:   self,
        module:   sql_account_module,
        username: sql_account_username
      )
    end
  end
end