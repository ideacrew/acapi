module Acapi
  module Subscribers

    class EnterpriseLogger < ::Acapi::Subscribers::Base

      def forward_event(event)

        Acapi::EnterpriseLogger.log(event.payload[:person])
      end
    end

  end
end