module Acapi
  module Publishers
    class AddressChange
      include Acapi::Publisher

      self.pub_sub_namespace = 'address_changed'
    end
  end

  # broadcast event
  if person.save
    Acapi::Publishers::Registration.broadcast_event('person_address_changed', person: person)
  end
end