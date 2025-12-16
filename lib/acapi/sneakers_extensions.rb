require "sneakers"

module Acapi
  module SneakersExtensions
    module QueueExtensions
      def connection
        @bunny
      end
    end
    module WorkerExtensions
      def connection
        queue.connection
      end

      def with_confirmed_channel
        chan = connection.create_channel
        begin
          chan.confirm_select
          yield chan
          chan.wait_for_confirms || raise(Acapi::Errors::PublishConfirmationFailedError, "message publication could not be confirmed")
        ensure
          chan.close
        end
      end
    end
  end
end

Sneakers::Queue.class_eval do
  include Acapi::SneakersExtensions::QueueExtensions
end

Sneakers::Worker.module_eval do
  include Acapi::SneakersExtensions::WorkerExtensions
end
