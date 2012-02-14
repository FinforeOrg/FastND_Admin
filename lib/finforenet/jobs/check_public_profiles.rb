module Finforenet
  module Jobs
    class CheckPublicProfiles
      @queue = "CheckPublicProfiles"

      def self.perform(user_id)
        Finfore::Jobs::ValidateProfiles.new(user_id)
      end

    end
  end
end
