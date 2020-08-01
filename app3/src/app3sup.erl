-module(app3sup).
-behaviour(supervisor).
-export([start_link/0,init/1,ch/1]).
-define(SERVER,?MODULE).
start_link()->
    supervisor:start_link({local,?SERVER},?MODULE,[]).
    


init(Arg)->
    MaxRestart=3,
    MaxTime=1000,
    SupFlags={one_for_all,MaxRestart,MaxTime},
    Spec=#{
        id=>app3sup,
        start=>{proc,start,[]},
        restart=>permanent,
        shutdown=>brutal_kill,
        type=>worker,
        modules=>[proc]},
    Ret={ok,{SupFlags,[Spec]}},
    Ret.

ch(Sup)->
    supervisor:start_child(Sup,[]).