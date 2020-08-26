-module(worker).
-export([start/0,loop/0]).

start()->
    Pid=spawn_link(?MODULE,loop,[]),
    {ok,Pid}.
loop()->
    receive 
        {From,Msg} -> From ! {processed,Msg},
                      notifyCompletionToServer(),
                      loop()
    end.

notifyCompletionToServer()->
    case whereis(server) of
        undefined -> exit(server_down);
        Pid -> Pid ! {worker_done,self()}
    end.