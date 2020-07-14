-module(worker).
-export([worker/1]).
-define(PROC_SLEEP,2000).


worker(MPid)->
    receive 
        {From,MSG} ->
            timer:sleep(?PROC_SLEEP),
            From ! {processed,MSG},
            MPid ! {worker,{finished,MSG}},
            worker(MPid);
        _ ->exit(bad_msg)
    
    end.