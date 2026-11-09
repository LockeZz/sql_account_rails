module SqlAccount
  module SupplierKnockoffGuard 
    extend ActiveSupport::Concern

    included do 
      class_attribute :knockoff_doctype, instance_writer: false

      # prepend: run before dependent: :destroy and before audit callbacks
      before_destroy :check_not_knocked_off, prepend: true
    end

    def knocked_off?
      if knockoff_doctype.blank?
        raise NotImplementedError, "#{self.class.name} must set knockoff_doctype"      end
      end

      SqlAccount::SupplierKnockoff.involving(knockoff_doctype, dockey).exists?
    end

    private

    def check_not_knocked_off
      return unless knocked_off?
      
      errors.add(:base, "Cannot delete #{self.class.name.demodulize} '#{docno}' - it has been knocked off by a payment or credit note")
      throw(:abort)
    end

  end
end