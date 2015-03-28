module Acapi
  module Publishers
    module CorpLogger
      extend ActiveSupport::Concern

      def corp_logger_notification(payload={}, &blk)
        payload.merge!(blk: blk) if block_given?
        Acapi::Publishers.broadcast_event("logger", payload)
      end

      def corp_edi_notification(payload={}, &blk)
        payload.merge!(blk: blk) if block_given?
        Acapi::Publishers.broadcast_event("edi", payload)
      end
    end
  end
end
