require 'spec_helper'

require 'acapi/railties/amqp_configuration_options'

shared_examples "an acapi amqp configuration" do |args|
  args.each do |arg|
    it "should allow configuration of :#{arg}" do
      expect(Rails.application.config.acapi).to respond_to(arg)
      expect(Rails.application.config.acapi).to respond_to("#{arg}=".to_sym)
    end
  end
end

describe "with the proper rails configuration options" do
  it_behaves_like "an acapi amqp configuration", [:remote_broker_uri, :remote_event_queue, :remote_request_exchange]

end
