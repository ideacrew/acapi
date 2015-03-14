module Acapi
  module Publishers

  # Hook into model callback chain when a publisher is attached to a model 
  # capture changes before_save and publish in after_save
  # start publishing created and destroyed notification

    module Base
      extend ActiveSupport::Concern

      # inject a reader to handle notifications for model in namespaces
      def pub_sub_notifications
        @pub_sub_notifications ||= ::Publishers::PubSubNotifications.new(self)
      end

      module ClassMethods
        def attach_publisher(namespace, publisher_class)
          # attach publisher to model class
          after_initialize do |model|
            model.pub_sub_notifications.attach_publisher(namespace, publisher_class)
          end

          # emit created notification and let the publisher hook into the notifications
          before_save do |model|
            model.pub_sub_notifications.prepare_created(namespace)
            model.pub_sub_notifications.prepare_notifications(namespace)
          end

          # publish notifications after save
          after_save do |model|
            model.pub_sub_notifications.publish_notifications(namespace)
          end

          # emit destroy notification and publish notifications
          after_destroy do |model|
            model.pub_sub_notifications.prepare_destroyed(namespace)
            model.pub_sub_notifications.publish_notifications(namespace)
          end
        end
      end

    end
  end
end