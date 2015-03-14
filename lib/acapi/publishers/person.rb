module Acapi
  module Publishers
    module Person
      def prepare_notifications(namespace, person)

        if person.identifying_info_changed?
          person.pub_sub_notifications.add_notification(namespace, 'identifying_info_changed', changes: person.name_changes)
        end
        
      end
    end
  end
end
