class AccessLog
    def self.debug(message)
        @my_log ||= Logger.new(File.join(Rails.root, "log", "auth_hub_#{Rails.env}_access.log"))
        @my_log.debug(message) 
    end

end