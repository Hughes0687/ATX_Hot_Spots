module RPS
  class UserSignIn
    def self.run(params)
      # params = {:username, :password}
      user = RPS::User.get_user_object_by_username(params[:username])

      if  user == nil
        return {
          :success? => false,
          :error => :no_user_exist,
          :sesh_id => nil,
          :user => nil
        }
      elsif user.has_password?(params[:password]) == false 
        return {
          :success? => false,
          :error => :invalid_password,
          :sesh_id => nil,
          :user => nil
        }
      else user.has_password?(params[:password]) == true
        sesh_id = user.create_session
        user = user.save!
        return {
          :success? => true,
          :error => nil,
          :sesh_id => sesh_id,
          :user => user
        }
      end
    end
  end
end




















