module Acapi
  module Publishers
    module EdiEvent
      extend ActiveSupport::Concern

      def edi_event(msg="", &blk)
        payload = {body: msg}
        payload.merge!(blk: blk) if block_given?
        Acapi::Publishers.broadcast_event("acapi.edi_event", payload)
      end
    end
  end
end
