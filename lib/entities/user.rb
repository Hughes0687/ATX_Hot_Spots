require 'digest'

module RPS
  class User
    attr_accessor :username, 
      :id,
      :password_digest,
      :wins,
      :losses,
      :session_id
    def initialize(
      username,
      id=nil,
      password_digest=nil,
      wins=0,
      losses=0,
      session_id = nil
    )
      @id = id
      @username = username
      @password_digest = password_digest
      @wins = wins
      @losses = losses
      @session_id = session_id
    end
    def create!
      id_from_db = RPS.orm.create_user(@username)
      return nil if id_from_db == nil
      @id = id_from_db
      self
    end
    def save!
      id_from_db = RPS.orm.update_user(
        @username,
        @id,
        @password_digest,
        @wins,
        @losses,
        @session_id
      )
      self
    end
    def update_password(password)
      @password_digest =  Digest::SHA1.hexdigest(password)
    end
    def has_password?(password)
      @password_digest ==  Digest::SHA1.hexdigest(password)
    end

    def create_session
      random_phrase = rand(100).to_s + username + rand(100).to_s
      @session_id = Digest::SHA1.hexdigest(random_phrase)
    end

    def pending_match
      match_info = RPS.orm.get_match_info_by_user_id(@id)
      return nil if match_info == nil
      match = RPS::Match.get_match_object_by_match_id(match_info.first["id"].to_i)
      return match
    end

    def pending_matches
      match_info = RPS.orm.get_match_info_by_user_id(@id)
      return nil if match_info == nil
      return match_info
    end

    def self.get_user_object_by_username(username)
      params = RPS.orm.get_user_info_by_username(username)
      return nil if params.empty?
      user = RPS::User.new(
        params.first["username"],
        params.first["id"].to_i,
        params.first["password_digest"],
        params.first["wins"].to_i,
        params.first["losses"].to_i,
        params.first["session_id"]
      )
      return user
    end

    def self.get_user_object_by_user_id(user_id)
      params = RPS.orm.get_user_info_by_user_id(user_id)
      return nil if params.empty?
      user = RPS::User.new(
        params.first["username"],
        params.first["id"].to_i,
        params.first["password_digest"],
        params.first["wins"].to_i,
        params.first["losses"].to_i,
        params.first["session_id"]
      )
      return user
    end

    def self.get_user_object_by_session_id(session_id)
      params = RPS.orm.get_user_info_by_session_id(session_id)
      return nil if params.empty?
      user = RPS::User.new(
        params.first["username"],
        params.first["id"].to_i,
        params.first["password_digest"],
        params.first["wins"].to_i,
        params.first["losses"].to_i,
        params.first["session_id"]
      )
      return user
    end

    def self.get_all_user_objects
      params = RPS.orm.get_all_users_info
      return nil if params.empty?
      return params
    end
  end
end






