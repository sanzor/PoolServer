-module(proc).
-export([start/0]).

start()->
    Pid=spawn_link(?MODULE,loop,[]),
    {ok,Pid}.

loop()->
    receive 
        {From,Message}-> From !  {ok,Message},
                         loop();
        _ ->loop()
    end.