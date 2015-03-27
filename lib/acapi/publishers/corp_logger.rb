module Acapi
  module Publishers
    module CorpLogger
      extend ActiveSupport::Concern

      def corp_logger_notification(msg)
        Acapi::Publishers.broadcast_event("logger", plan: msg)
      end

      module ClassMethods
        def corp_logger_on(method_name, msg)
          new_method = "new_" << method_name.to_s
          old_method = "old_" << method_name.to_s

          define_method new_method do
            self.send(old_method)
            corp_logger_notification(msg)
          end
          
          alias_method old_method, method_name 
          alias_method method_name, new_method

          #flag = false
          #define_singleton_method :method_added do |name|
          #    puts "add #{name}"
          #  if name == method_name && flag == false 
          #    puts "add #{name}"
          #    flag = true
          #    alias_method old_method, method_name 
          #    alias_method method_name, new_method
          #  end 
          #end 
        end
      end 

      #def prepare_notifications(namespace, family)

      #  if family.location_changed?
      #    family.pub_sub_notifications.add_notification(namespace, 'location_changed', changes: family.location_change)
      #  end
      #  
      #  if family.dependent_added?
      #    family.pub_sub_notifications.add_notification(namespace, 'dependent_added', changes: family.dependent_add)
      #  end 
      #end
    end
  end
end
