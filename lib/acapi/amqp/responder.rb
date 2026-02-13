module Acapi
  module Amqp
    module Responder
      def with_response_exchange(connection)
        channel = connection.create_channel
        channel.confirm_select
        publish_exchange = channel.default_exchange
        yield publish_exchange
        channel.wait_for_confirms || raise(Acapi::Errors::PublishConfirmationFailedError, "message publication could not be confirmed")
        channel.close
      end
    end
  end
end
