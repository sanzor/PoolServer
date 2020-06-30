-module(mq).
-compile(export_all).

-record(monstate,{
    queue,
    qc,
    wpid,
    free=true,
    wref,
    init=false,
    frun=false
}).
-record(sstate,{
    init=false,
    mpid=null,
    mref=null
}).

-define(QUEUE_SIZE,5).
-define(PROC_SLEEP,2000).


createProcess({M,F,A})->
    Pid=spawn(M,F,[A]),
    Ref=erlang:monitor(process,Pid),
    {Pid,Ref}.

start()->
    spawn(?MODULE,server,[#sstate{init=false}]).

server(State=#sstate{init=I})when I=:=false ->
    {MPid,MRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
    server(State#sstate{init=true,mpid=MPid,mref=MRef});

server(State=#sstate{mpid=MPid,mref=MRef})->
    receive
           {From,state}->From ! State,
                            server(State);
           {From,Message}-> MPid ! {request,{From,Message}},
                            server(State);
                
            {'DOWN',MRef,process,MPid,_}-> {NewMPid,NewMRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
                                            server(State#sstate{mpid=NewMPid,mref=NewMRef});
            _ ->exit(invalid_message)
                                    
    end.
  

tryEnqueue(Message,MState=#monstate{queue=Q,qc=C}) when C<?QUEUE_SIZE->
    NewQueue=queue:in(Message,Q),
    {queued,MState#monstate{qc=C+1,queue=NewQueue}};
tryEnqueue(_,MState)->{queue_full,MState}.

monitor(MState=#monstate{wpid=_,wref=_,init=I}) when I=:= false ->
    {WorkerPid,WorkerRef}=createProcess({?MODULE,worker,self()}),
    monitor(MState#monstate{wpid=WorkerPid,wref=WorkerRef,init=true,qc=0,queue=queue:new(),frun=true});

monitor(MState=#monstate{wpid=W,free=F,wref=Ref,queue=Q,qc=C,frun=R})->
    receive
        {From,isFree}->From !{workerstate,F},monitor(MState);
        {request,{From ,Message}} ->  
                                       {Result,NewState}=tryEnqueue({From,Message},MState),
                                        case Result of 
                                            queue_full -> From ! {queue_full,Message};
                                            _ -> ok
                                        end,
                                        case R of
                                            true -> self() ! {worker,{finished,R}},
                                                    monitor(NewState#monstate{frun=false});
                                            false -> monitor(NewState#monstate{frun=false})
                                        end;
                                       

        {worker,{finished,_}}-> case queue:out(Q) of
                                    {{_,Element},Rest} -> W ! Element,
                                                    monitor(MState#monstate{free=false,queue=Rest,qc=C-1});
                                    {empty,Rest} -> monitor(MState#monstate{free=true,queue=Rest})
                                end;

        {'DOWN',Ref,process,_,_}->
             {NewWorkerPid,NewWorkerRef}=createProcess({?MODULE,worker,self()}),
             monitor(MState#monstate{wpid=NewWorkerPid,wref=NewWorkerRef,free=true});

        _->exit(invalid_message)

    end.

worker(MPid)->
    receive 
        {From,MSG} ->
            timer:sleep(?PROC_SLEEP),
            From ! {processed,MSG},
            MPid ! {worker,{finished,MSG}},
            worker(MPid);
        _ ->exit(bad_msg)
    end.

