# be ruby lib/databases/tables_initializer.rb

require 'pg'

db = PG.connect(host: 'localhost', dbname: 'RPS_db')

command = <<-SQL
CREATE TABLE users(
   id SERIAL,
   username text,
   password_digest text,
   wins integer,
   losses integer,
   session_id text,
   PRIMARY KEY( id )
);

CREATE TABLE matches(
   id SERIAL,
   user1_id integer,
   user2_id integer,
   user1_game_wins integer,
   user2_game_wins integer,
   user1_move text,
   user2_move text,
   game_history_hash text,
   last_game_winner_id integer,
   match_winner_id integer,
   PRIMARY KEY( id )
);
SQL
result = db.exec(command)
p result.values