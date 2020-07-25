-module(mapp).
-behaviour(application).
-export([start/2,stop/1]).

start(normal,_Args)->
    Pid=m1:start_link(),
    {ok,Pid}.

stop(State)->ok.
