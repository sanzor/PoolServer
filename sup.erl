-module(sup).
-behaviour(supervisor).
-export([init/1,run/1]).



run({Name,Strategy})->
    supervisor:start_link({local,Name},?MODULE,[Strategy]).
 
init(Strategy)->
   ChildSpec=#{
       id=>wk,
       start=>{wk,start_link,[]},
       restart=>transient,
       timeout=>brutal_kill,
       type=>worker,
       modules=>[wk]
   },
   {ok,{Strategy,[ChildSpec]}}.


