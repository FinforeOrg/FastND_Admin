module Finforenet
  module Jobs
    class ValidateProfiles

      def initialize(user_id)
        start(user_id)
      end

      def start(user_id)
        user = User.find user_id
        profiles = []
        users = User.find(:all,:include=>[:profiles],:conditions => ["users.is_public IS TRUE AND users.id != ?", user.id])
        categories = ProfileCategory.all(:select=>"id")
        categories.each do |category|
          user_profiles = user.profiles.find(:all,:include=>[:profile_category],:conditions=>["profile_categories.id = ?",category.id]).map(&:id)
          profiles.push(user_profiles)
        end

        reports = {}

        combination_profiles = variations(profiles)

        combination_profiles.each do |combination|
          ids = combination.split(/\s/).compact.map{|v| v.to_i}
          match_list = Profile.find(:all,:conditions=>["id IN (?)",ids]).map(&:title).join(" / ")

          users.each do |p_user|
            user_ids = p_user.profiles.map(&:id)
            remain = user_ids - ids
            expectation = user_ids.size - ids.size
	    if remain.size == expectation
	      reports[p_user.login] ||= []
	      reports[p_user.login].push(match_list)
	    end
          end
        end

        unless reports.blank?
          UserMailer.deliver_alert_duplication(user,reports)
        end

      end


      def variations(info)
        first = info.first
        if info.length == 1
          first
        else
          rest = variations(info[1..-1])
          first.map{ |x| rest.map{ |y| "#{x} #{y} " } }.flatten
        end
      end

    end
  end
end


