module Acapi
  module Amqp
    module Responder
      def with_response_exchange(connection)
        channel = connection.create_channel
        publish_exchange = channel.default_exchange
        yield publish_exchange
        channel.close
      end
    end
  end
end
