-module(m1).
-include("r.hrl").
-export([start_link/0]).

start_link()->
    Pid=spawn_link(?MODULE,serv,#state{count=2}),
    Pid.
serv(State=#state{count=C})->
    receive 
        {From,MSG} ->From ! {ok,MSG},
                     serv(State#state{count=C=1})
    end.