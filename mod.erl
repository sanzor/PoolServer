-module(mod).
-export([loop/0]).
loop()->
    receive
        {From,a}->From  !b,loop();
        {From,Message}->
            timer:sleep(20000),
            From ! done_sleeping,loop()
        end.
        