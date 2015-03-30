module Acapi
  module Publishers
    module Logger
      extend ActiveSupport::Concern

      def logger(msg="", &blk)
        payload = {body: msg}
        payload.merge!(blk: blk) if block_given?
        Acapi::Publishers.broadcast_event("acapi.logger", payload)
      end
    end
  end
end
