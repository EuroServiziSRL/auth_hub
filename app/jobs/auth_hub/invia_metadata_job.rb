module AuthHub
  class InviaMetadataJob < ApplicationJob
    queue_as :default
  
    def perform(*args)
      logger.debug "\n\n Sono lo scheduler \n\n"
    end
  end  
end
