-module(wsup).
-behaviour(supervisor).
-export([init/1]).


init(Args)->
    SupFlags=#{
        strategy=>simple_one_for_one,
        intensity=>3,
        period=>2500
        },
    ChildSpec=#{
         id=>worker,
         start=>{worker,start_link,Args},
         restart=>transient,
         timeout=>brutal_kill,

         type=>worker,
         modules=>[worker]
        },
    {ok,{SupFlags,[ChildSpec]}}.
