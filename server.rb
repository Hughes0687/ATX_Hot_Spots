require_relative 'lib/RPS.rb'
require 'sinatra'
require 'pry'
require 'shotgun'
# require 'sinatra-contrib'

enable :sessions 

set :bind, '0.0.0.0' # This is needed for Vagrant

get '/' do
  erb :map
end

get '/sign_up' do
  @result =  {
    :success? => nil,
    :error => nil,
    :sesh_id => nil,
    :user => nil
  }
  erb :sign_up
end

post '/sign_up' do
  @result = RPS::UserSignUp.run(params)
  if @result[:success?]
    session[:sesh_id] = @result[:sesh_id]
    session[:user_id] = @result[:user].id
    redirect to '/user_homepage'
  else
    erb :sign_up
  end
end

get '/sign_in' do
  if session[:sesh_id]
    user = RPS::User.get_user_object_by_session_id(session[:sesh_id])
    session[:sesh_id] = user.session_id
    session[:user_id] = user.id
    redirect to '/user_homepage'
  else
    @result = {
      :success? => nil,
      :error => nil,
      :sesh_id => nil,
      :user => nil
    }
    erb :sign_in
  end
end

post '/sign_in' do
  @result = RPS::UserSignIn.run(params)
  if @result[:success?]
    session[:sesh_id] = @result[:sesh_id]
    session[:user_id] = @result[:user].id
    redirect to '/user_homepage'
  else
    erb :sign_in
  end
end

get '/user_homepage' do
  @user = RPS::User.get_user_object_by_user_id(session[:user_id])
  @matches = @user.pending_matches
  @matches = [] if @matches == nil 
  erb :user_homepage
end

# get '/new_game' do
#   result = RPS::NewMatch.run(session[:user_id])

#   @user1 = result[:user1]
#   @user2 = result[:user2]
#   @match = result[:match]
#   @user_index = result[:user_index]
#   @opponent_index = result[:opponent_index]

#   session[:user1_id] = @user1.id
#   session[:user2_id] = @user2.id
#   session[:match_id] = @match.match_id
#   session[:user_index] = @user_index
#   session[:opponent_index] = @opponent_index

#   erb :match_homepage
# end


# get '/continue_game/:user_id/:match_id' do |user_id, match_id|
#   result = RPS::ContinueMatch.run(user_id.to_i, match_id.to_i)

#   @user1 = result[:user1]
#   @user2 = result[:user2]
#   @match = result[:match]
#   @user_index = result[:user_index]
#   @opponent_index = result[:opponent_index]

#   session[:user1_id] = @user1.id
#   session[:user2_id] = @user2.id
#   session[:match_id] = @match.match_id
#   session[:user_index] = @user_index
#   session[:opponent_index] = @opponent_index

#   erb :match_homepage
# end

# post '/made_move' do
#   RPS::Turn.run(session, params)
#   user_id = session[:user1_id] if session[:user_index] == 0
#   user_id = session[:user2_id] if session[:user_index] == 1
#   match_id = session[:match_id]
#   redirect to "/continue_game/#{user_id}/#{match_id}"
# end

get '/leaderboard' do
  results = RPS::User.get_all_user_objects
  @scores = []
  results.each do |user|
    @scores << {username: user["username"], id: user["id"].to_i, wins: user["wins"].to_i, losses: user["losses"].to_i}
  end
  @highscores = @scores.sort_by {|user| -user[:wins]}
  erb :leaderboard
end

get '/logout' do
  session.clear
  redirect to '/'
end

get '/contact' do
  erb :contact
end
