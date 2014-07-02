module RPS
  class ContinueMatch
    def self.run(user_id, match_id)
      user = RPS::User.get_user_object_by_user_id(user_id)
      match = RPS::Match.get_match_object_by_match_id(match_id)
      user1 = match.user1
      user2 = match.user2

      if user_id == user1.id
        user_index = 0 
        opponent_index = 1
      end
      if user_id == user2.id
        user_index = 1
        opponent_index = 0
      end

      return {
        :user1 => user1,
        :user2 => user2,
        :match => match,
        :user_index => user_index,
        :opponent_index => opponent_index
      }
    end
  end
end
