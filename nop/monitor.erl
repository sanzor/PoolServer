-module(monitor).
-export([monitor/1]).
-import(common,[createProcess/1]).
-include("records.hrl").

-define(QUEUE_SIZE,5).


tryEnqueue(Message,MState=#monstate{queue=Q,qc=C}) when C<?QUEUE_SIZE->
    NewQueue=queue:in(Message,Q),
    {queued,MState#monstate{qc=C+1,queue=NewQueue}};
tryEnqueue(_,MState)->{queue_full,MState}.

monitor(MState=#monstate{wpid=_,wref=_,init=I}) when I=:= false ->
    {WorkerPid,WorkerRef}=createProcess({?MODULE,worker,self()}),
    monitor(MState#monstate{wpid=WorkerPid,wref=WorkerRef,init=true,qc=0,queue=queue:new()});

monitor(MState=#monstate{wpid=W,free=Free,wref=Ref,queue=Q,qc=C})->
    receive
        
        {request,{From ,Message}} -> case Free of 
                                            true -> W ! {From,Message},
                                                    monitor(MState#monstate{free=false});
                                                                             
                                            false -> 
                                                     St=case tryEnqueue({From,Message},MState) of 
                                                            {queue_full,S} -> From ! {queue_full,Message},S;
                                                            {queued,S} -> S
                                                        end,
                                                      monitor(St)
                                      end;
                                         
                                        
                                      
                                  
        {worker,{finished,_}}-> case queue:out(Q) of
                                    {{_,Element},Rest} -> W ! Element,
                                                          monitor(MState#monstate{free=false,queue=Rest,qc=C-1});
                                    {empty,Rest}       -> monitor(MState#monstate{free=true,queue=Rest})
                                end;

        {'DOWN',Ref,process,_,_}->
             {NewWorkerPid,NewWorkerRef}=createProcess({?MODULE,worker,self()}),
             monitor(MState#monstate{wpid=NewWorkerPid,wref=NewWorkerRef,free=true});

        _->exit(invalid_message)

    end.
