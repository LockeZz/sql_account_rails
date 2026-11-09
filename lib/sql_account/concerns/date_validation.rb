module SqlAccount
  module DateValidation
    extend ActiveSupport::Concern

    # Off by default. Switch on with:  SqlAccount.configuration.validate_allowed_dates = true

    included do
      validate :postdate_within_allowed_range, if: :validate_allowed_postdate?
    end

    private

    def validate_allowed_postdate?
      SqlAccount.configuration.validate_allowed_dates &&
        respond_to?(:postdate) && postdate.present?
    end


    def postdate_within_allowed_range
      return if SqlAccount::TransactionAllowDate.allowed?(postdate)

      ranges = SqlAccount::TransactionAllowDate.global.order(:datefrom).map do |r|
        "#{r.datefrom.strftime('%d/%m/%Y')} - #{r.dateto.strftime('%d/%m/%Y')}"
      end

      errors.add(:postdate,
        "#{postdate.strftime('%d/%m/%Y')} is outside the allowed transaction date range (#{ranges.join(', ')})")
    rescue ActiveRecord::ActiveRecordError => e
      # Only database errors are tolerated here. Programming errors (NameError,
      # NoMethodError ...) are deliberately NOT rescued so they show up.
      if defined?(Rails) && Rails.logger
        Rails.logger.warn("[SqlAccount] DateValidation check failed: #{e.message}")
      end
    end

  end
end