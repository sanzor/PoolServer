-module(gate).
-behaviour(supervisor).
-export([init/1]).



run()->
    supervisor:start_link({local,?MODULE},?MODULE,[]).


process()->
    


stop()->

init()->
    RestartStrategy={simple_one_for_one,1,1000},
    ChildSpec={
        wk,
        {wk,start_link,[]},
        transient,
        brutal_kill,
    }
    {ok,{RestartStrategy,[ChildSpec]}}.



