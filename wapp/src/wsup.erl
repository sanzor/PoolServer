-module(wsup).
-behaviour(supervisor).
-export([start_link/1,init/1]).

-define(SUP,?MODULE).

start_link()->
    
    {ok,Pid}=supervisor:start_link({local,?SUP},?MODULE,[]),
    {ok,Pid}.


init(Name)->
    Strategy=#{
        strategy=>simple_one_for_one,
        intensity=>5,
        timeout=>60
        },
    Spec=#{
        id=>child,
        start=>{worker,start,[Name]},
        restart=>transient,
        shutdown=>brutal_kill},
    {ok,{Strategy,Spec}}.
