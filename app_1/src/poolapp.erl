-module(poolapp).
-behaviour(application).
-export([start/2,stop/1]).

start(normal,_Args)->
    Pid=sv:start_link(),
    {ok,Pid}.

stop(_)->ok.