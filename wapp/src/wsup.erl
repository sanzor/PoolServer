-module(wsup).
-behaviour(supervisor).
-export([start_link/1,init/1]).



start_link(Name)when is_list(Name)->
    SupName=list_to_atom(Name++".sup"),
    {ok,Pid}=supervisor:start_link({local,SupName},?MODULE,[Name]),
    register(SupName,Pid),
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
