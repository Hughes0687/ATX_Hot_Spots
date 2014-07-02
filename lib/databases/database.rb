require 'pg'

module RPS
  class ORM
    def initialize 
      @db = PG.connect(host: 'localhost', dbname: 'RPS_db')
    end

    ##----------USER ORM METHODS----------------------
    def create_user(username)

      result = @db.exec(%Q[SELECT * FROM users WHERE username = '#{username}'])
      params = result.map{|x| x}
      return nil if !(params.empty?)

      command = <<-SQL
        INSERT INTO users(username)
        VALUES ('#{username}')
        returning id;
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params.first["id"].to_i
    end

    def get_user_info_by_username(username)
      command = <<-SQL
        SELECT * FROM users WHERE username = '#{username}'
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def get_user_info_by_user_id(user_id)
      command = <<-SQL
        SELECT * FROM users WHERE id = '#{user_id}'
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def get_user_info_by_session_id(session_id)
      command = <<-SQL
        SELECT * FROM users WHERE session_id = '#{session_id}'
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def update_user(username, id, password_digest, wins, losses, session_id)
      command = <<-SQL
        UPDATE users 
        SET (username, password_digest, wins, losses, session_id) = 
        ('#{username}', '#{password_digest}', '#{wins}', '#{losses}', '#{session_id}')
        WHERE id = '#{id}'
        returning *;
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def get_all_user_ids
      command = <<-SQL
        SELECT id FROM users;
      SQL
      result = @db.exec(command)
      params = result.values.flatten.map! {|x| x.to_i}
      return params
    end

    def get_all_users_info
      command = <<-SQL
        SELECT * FROM users;
      SQL
      result = @db.exec(command)
      params = result.map {|x| x}
      return params
    end

    ##----------MATCH ORM METHODS----------------------
    def create_match(user1_id)
      command = <<-SQL
        INSERT INTO matches(user1_id, user2_id, user1_game_wins, user2_game_wins, user1_move, user2_move, game_history_hash, last_game_winner_id, match_winner_id)
        VALUES ('#{user1_id}', '#{0}', '#{0}', '#{0}', '#{nil}', '#{nil}', '#{''}', '#{0}', '#{0}')
        returning id;
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params.first["id"].to_i
    end

    def update_match(
      user1_id,
      user2_id,
      user1_game_wins,
      user2_game_wins,
      user1_move,
      user2_move,
      game_history_hash,
      last_game_winner_id,
      match_winner_id,
      match_id
    )
      command = <<-SQL
        UPDATE matches 
        SET (user1_id, user2_id, user1_game_wins, user2_game_wins, user1_move, user2_move, game_history_hash, last_game_winner_id, match_winner_id) = 
        ('#{user1_id}','#{user2_id}','#{user1_game_wins}','#{user2_game_wins}','#{user1_move}','#{user2_move}','#{game_history_hash}','#{last_game_winner_id}','#{match_winner_id}')
        WHERE id = '#{match_id}'
        returning *;
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def get_match_info_by_match_id(match_id)
      command = <<-SQL
        SELECT * FROM matches WHERE id = '#{match_id}'
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return params
    end

    def get_match_info_by_user_id(user1_id)
      command = <<-SQL
        SELECT * FROM matches WHERE (user1_id = '#{user1_id}' OR user2_id = '#{user1_id}') AND match_winner_id = 0
      SQL
      result = @db.exec(command)
      params = result.map{|x| x}
      return nil if params.empty?
      return params
    end

  end

  def self.orm
    @__db__ ||= ORM.new
  end
end