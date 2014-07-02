module RPS
  class Turn
    def self.run(session, params)
      match = RPS::Match.get_match_object_by_match_id(session[:match_id])
      match.user1_move = params["choice"] if session[:user1_id] == session[:user_id]
      match.user2_move = params["choice"] if session[:user2_id] == session[:user_id]
      match.save!

      if match.moves_made? == [true, true]
        match.game_winner
        match.add_to_history
        match.clear_moves
        match.save!
      end

      match.game_over?
      match.save!
    end
  end
end