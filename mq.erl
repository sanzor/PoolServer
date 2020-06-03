-module(mq).
-compile(export_all).
-record(enqstate,{
    queue,
    queueCount
}).
-record(procstate,{
    
}).
-define(QUEUE_SIZE,5).
-define(PROC_SLEEP,1000).

start()->
    spawn(?MODULE,init,[]).
init()->
    EnqueuerPid=spawn(?MODULE,enqueuer,#enqstate{queue=queue:new(),queueCount=0}),
    ProcessorPid=spawn(?MODULE,processor,#procstate{}),
    loop(EnqueuerPid).

loop(EnqueuerPid) ->
    receive
        {From,Msg} -> EnqueuerPid ! {From,Msg};
         _ -> exit(invalid_message) 
    end


enqueuer(State#enqstate{queueCount=C,queue=Q})
    receive 
        {From,MSG}-> if C<?QUEUE_SIZE -> NewQueue=queue:in({FROM,MSG},Q),
                                         enqueuer(State#enqstate{queueCount=C+1,queue=NewQueue});
                         true         -> From ! {queue_full_try_later},
                                         enqueuer(State)
                     end
        {ProcessorPid,msg_processed}-> 
                                 case queue:out(Q) of
                                     {{value,Element},RemQueue} ->
                                              ProcessorPid ! {self(),Element},
                                              enqueuer(State#state{queueCount=C-1,queue=RemQueue});
                                      {empty,_} -> enqueuer(State)
    end.
        
processor(ProcState#procstate)->
    receive 
        {EnqPid,{From,Message}}->
                timer:sleep(?PROC_SLEEP),
                From ! {Message,processed},
                EnqPid ! {self(),msg_processed},
                processor(ProcState);

         _ ->processor(ProcState)
    end.