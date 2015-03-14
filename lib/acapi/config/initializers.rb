module Acapi
  module Config
    module Initializers

      ## Event subscribers
      # Log events
      # Acapi::Subscribers::EnterpriseLogger.attach_to('log')    

      # Enrollment events
      # Acapi::Subscribers::NoticeMailer.attach_to('notice')

      # EDI events
      # Acapi::Subscribers::EdiEvent.attach_to('edi')

    end
  end
end