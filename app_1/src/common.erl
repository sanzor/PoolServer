%%% common functionality module
-module(common).
-export([createProcess/1]).
-include("records.hrl").

createProcess({M,F,A})->
    Pid=spawn(M,F,[A]),
    Ref=erlang:monitor(process,Pid),
    {Pid,Ref}.
