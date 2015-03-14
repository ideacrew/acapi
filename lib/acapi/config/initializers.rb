module Acapi
  module Config
    module Initializers

      ## Event subscribers
      # Log events
      # Subscribers::EnterpriseLogger.attach_to('log')    

      # Enrollment events
      # Subscribers::NoticeMailer.attach_to('notice')

      # EDI events
      # Subscribers::EdiEvent.attach_to('edi')

    end
  end
end