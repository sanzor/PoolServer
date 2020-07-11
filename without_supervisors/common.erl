-module(common).
-export([createProcess/1]).

createProcess({M,F,A})->
    Pid=spawn(M,F,[A]),
    Ref=erlang:monitor(process,Pid),
    {Pid,Ref}.
