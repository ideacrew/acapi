module Acapi
  module Subscribers

    class EnterpriseLogger < ::Subscribers::Base

      def user_signed_up(event)
        # lets delay the delivery using delayed_job
        EnterpriseLogger.log(event.payload[:person])
      end
    end

  end
end