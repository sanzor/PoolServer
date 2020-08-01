-module(proc).
-export([start/0,loop/0]).

start()->
    Pid=spawn_link(?MODULE,loop,[]),
    {ok,Pid}.
loop()->
    receive 
        {From,Msg} -> From ! {processed,Msg},
                      loop()
    end.