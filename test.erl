-module(test).
-record(state,{
    wk
}).
-export([worker/0,run/0,loop/1,call/2]).
-define(EXISTS(State),State#state.wk=/=undefined).
-define(PRINT(X),io:format("~p",[X])).
-define(DELAY,10000).

run()->
    spawn(?MODULE,loop,[#state{}]).

loop(State=#state{wk=W})->
    receive 
        {FROM,MSG} ->
            % WorkerPid= if not (?EXISTS(W)) -> spawn(test,worker,[]);
            %               true -> W
            %            end,
            % ?PRINT(MSG),
            (A=spawn(test,worker,[]))!{FROM,MSG},
            
            loop(State#state{wk=A})
    end.


worker()->
    receive 
        {FROM,MSG} -> timer:sleep(?DELAY),
                      FROM ! {processed,MSG},
                      worker()

    end.

call(Message,Mid)->
    Mid ! {self(),Message},
    receive 
        {processed,NewMessage}->NewMessage
    end.