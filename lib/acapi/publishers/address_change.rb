module Acapi
  module Publishers
    class AddressChange
      include Publisher

      self.pub_sub_namespace = 'address_changed'
    end
  end

  # broadcast event
  if person.save
    Publishers::Registration.broadcast_event('person_address_changed', person: person)
  end
end