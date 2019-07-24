module Acapi
  class ConfigurationSettings
    # :nodoc:
    # @private
    def constantize_worker_class(sub_name)
      return(sub_name) unless sub_name.kind_of?(String)
      sub_name.constantize
    end

    def add_amqp_worker(worker, count = 1)
      @amqp_event_workers ||= []
      count.times do
        @amqp_event_workers << worker
      end
      @amqp_event_workers.uniq!
    end

    # :nodoc:
    # @private
    def sneakers_worker_classes
      @sneakers_worker_classes ||= []
    end

    def register_amqp_workers!
      @amqp_event_workers ||= []
      @sneakers_worker_classes = []
      @amqp_event_workers.each do |sub|
        worker_class = constantize_worker_class(sub)
        worker_class.worker_specification.execute_sneakers_config_against(worker_class)
        @sneakers_worker_classes << worker_class
      end
    end
  end
end
