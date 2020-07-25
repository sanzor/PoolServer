-module(papp2).
-behaviour(application).
-export([start/2,stop/1]).

start(normal,_)->
    Pid=server:startall(),
    {ok,Pid}.
stop(_)->ok.