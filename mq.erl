-module(mq).
-compile(export_all).
-record(enqstate,{
    queue,
    queueCount
}).
-record(sstate,{
    eref,
    pref
}).
-define(QUEUE_SIZE,5).
-define(PROC_SLEEP,1000).
-compile(export_all).

start()->
    spawn(?MODULE,server,[]).
server()->
    EnqueuerPid=spawn(?MODULE,enqueuer,[#enqstate{queue=queue:new(),queueCount=0}]),
    ProcessorPid=spawn(?MODULE,processor,[]),
    ERef=erlang:monitor(EnqueuerPid),
    PRef=erlang:monitor(ProcessorPid),
    loop(#sstate{eref=ERef,pref=PRef}).

loop(S=#sstate{eref=E,pref=P}) ->
    receive
        {'DOWN',E,process,Pid,Reason}->exit(enq_down);
        {'DOWN',P,process,Pid,Reason}->exit(proc_down);
        {From,Msg} -> EnqueuerPid ! {From,Msg};
         _ -> exit(invalid_message) 
    end.


enqueuer(State=#enqstate{queueCount=C,queue=Q})->
    receive 
        {From,MSG}-> if C<?QUEUE_SIZE -> NewQueue=queue:in({From,MSG},Q),
                                         enqueuer(State#enqstate{queueCount=C+1,queue=NewQueue});
                         true         -> From ! {queue_full_try_later},
                                         enqueuer(State)
                     end;
        {ProcessorPid,msg_processed}-> 
                                 case queue:out(Q) of
                                     {{value,Element},RemQueue} ->
                                              ProcessorPid ! {self(),Element},
                                              enqueuer(State#enqstate{queueCount=C-1,queue=RemQueue});
                                      {empty,_} -> enqueuer(State)
                                 end
    end.
        
processor()->
    receive 
        {EnqPid,{From,Message}}->
                timer:sleep(?PROC_SLEEP),
                From ! {Message,processed},
                EnqPid ! {self(),msg_processed},
                processor(ProcState);

         _ -> exit(wrong_message)
    end.