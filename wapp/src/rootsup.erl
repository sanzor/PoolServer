-module(rootsup).
-behaviour(supervisor).
-export([start_link/1,init/1]).

start_link(Name)->
    supervisor:start_link({local,?MODULE},?MODULE,Name).
    
init(Name)->
   Strategy=#{strategy=>one_for_all,intensity=>5,timeout=>5000},
   ServerSpec=#{
       id=>server,
       start=>{server,start_link,[Name]},
       restart=>permanent,
       shutdown=>5000,
       type=>worker,
       modules=>[server]
       },
    WsupSpec=#{
        id=>wsup,
        start=>{wsup,start_link,[Name]},
        restart=>permanent,
        shutdown=>brutal_kill,
        type=>supervisor
        },
    {ok,{Strategy,[WsupSpec,ServerSpec]}}.


