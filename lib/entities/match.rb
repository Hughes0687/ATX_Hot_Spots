module RPS
  class Match

    attr_accessor :user1,
      :user2,
      :user1_game_wins,
      :user2_game_wins,
      :user1_move,
      :user2_move,
      :game_history_hash,
      :last_game_winner_id,
      :match_winner_id,
      :match_id

    def initialize( 
      user1, 
      user2=nil,
      user1_wins=0, 
      user2_wins=0,
      user1_move="",
      user2_move="",
      game_history_hash="",
      last_game_winner_id=0,
      match_winner_id=0,
      id=nil
    )
      @user1 = user1
      @user2 = user2
      @user1_game_wins = user1_wins
      @user2_game_wins = user2_wins
      @user1_move = user1_move
      @user2_move = user2_move
      @game_history_hash = game_history_hash
      @last_game_winner_id = last_game_winner_id
      @match_winner_id = match_winner_id
      @match_id = id
    end

    def create!
      id_from_db = RPS.orm.create_match(@user1.id)
      return nil if id_from_db == nil
      @match_id = id_from_db
      self
    end

    def save!
      user1_id = 0
      user1_id = @user1.id if @user1 != nil
      user2_id = 0
      user2_id = @user2.id if @user2 != nil

      RPS.orm.update_match(
        @user1.id,
        @user2.id,
        @user1_game_wins,
        @user2_game_wins,
        @user1_move,
        @user2_move,
        @game_history_hash,
        @last_game_winner_id,
        @match_winner_id,
        @match_id,
      )
      self
    end

    def assign_random_opponent
      if @user2.nil?
        all_user_ids = RPS.orm.get_all_user_ids
        while @user2.nil?
          random_index = rand(all_user_ids.length)
          if all_user_ids[random_index] != @user1.id
            @user2 = RPS::User.get_user_object_by_user_id(all_user_ids[random_index])
          end
        end
      end
    end

    def moves_made?
      user1 = false
      user2 = false
      user1 = true if @user1_move != ""
      user2 = true if @user2_move != ""
      return [user1, user2]
    end

    def game_winner
      beats = {
        "rock" => "scissors",
        "paper" => "rock",
        "scissors" => "paper"
      }
      if user1_move == user2_move
        @last_game_winner_id = 0
        return "tie"
      elsif beats[user1_move] == user2_move
        @user1_game_wins += 1
        @last_game_winner_id = @user1.id
        return "user1_win"
      else
        @user2_game_wins += 1
        @last_game_winner_id = @user2.id
        return "user2_win"
      end
    end

    def clear_moves
      @user1_move = nil
      @user2_move = nil
    end

    def history_decoder
      games_hash = []
      games_hash += @game_history_hash.split(":")

      history = Hash.new(){nil}
      convert = {
        "r" => "rock",
        "p" => "paper",
        "s" => "scissors",
        "t" => "--><--",
        "1" => "<---",
        "2" => "--->"
      }

      games_hash.each_with_index do |game_hash, index|
        game_number = "game" + (index+1).to_s
        history[game_number.to_sym] = {}
        turn_hash = game_hash.split("*")

        history[game_number.to_sym][:user1_move] = convert[(turn_hash[0][1].to_s)]
        history[game_number.to_sym][:user2_move] = convert[(turn_hash[1][1].to_s)]
        history[game_number.to_sym][:winner] = convert[turn_hash[2][1].to_s]
      end
      return history
    end  

    def add_to_history
      w = 't'
      w = 1 if @last_game_winner_id == @user1.id
      w = 2 if @last_game_winner_id == @user2.id
      @game_history_hash << "1#{@user1_move.slice(0)}*2#{@user2_move.slice(0)}*w#{w}:"
    end

    def game_over?
      if @user1_game_wins == 3 || @user2_game_wins == 3
        if @user1_game_wins == 3
          @match_winner_id = @user1.id 
          @user1.wins += 1
          @user2.losses += 1
        end
        if @user2_game_wins == 3
          @match_winner_id = @user2.id 
          @user2.wins += 1
          @user1.losses += 1
        end
        @user1.save!
        @user2.save!
        return true
      else
        return false
      end
    end


    def self.get_match_object_by_match_id(match_id)
      params = RPS.orm.get_match_info_by_match_id(match_id)
      user1 = nil
      user2 = nil
      user1 = RPS::User.get_user_object_by_user_id(params.first["user1_id"].to_i) if params.first["user1_id"].to_i != 0
      user2 = RPS::User.get_user_object_by_user_id(params.first["user2_id"].to_i) if params.first["user2_id"].to_i != 0
      match = RPS::Match.new(
        user1,
        user2,
        params.first["user1_game_wins"].to_i,
        params.first["user2_game_wins"].to_i,
        params.first["user1_move"],
        params.first["user2_move"],
        params.first["game_history_hash"],
        params.first["last_game_winner_id"].to_i,
        params.first["match_winner_id"].to_i,
        params.first["id"].to_i
      )
      return match
    end
  end
end
