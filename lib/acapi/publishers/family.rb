module Acapi
  module Publishers
    module Family
      def prepare_notifications(namespace, family)

        if family.location_changed?
          family.pub_sub_notifications.add_notification(namespace, 'location_changed', changes: family.location_change)
        end
        
        if family.dependent_added?
          family.pub_sub_notifications.add_notification(namespace, 'dependent_added', changes: family.dependent_add)
        end
        
        if family.location_changed?
          family.pub_sub_notifications.add_notification(namespace, 'location_changed', changes: family.location_change)
        end
        
        if family.location_changed?
          family.pub_sub_notifications.add_notification(namespace, 'location_changed', changes: family.location_change)
        end
        
      end
    end
  end
end
