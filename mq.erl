-module(mq).
-compile(export_all).

-record(monstate,{
    wpid,
    free=true,
    wref,
    init=false
}).
-record(sstate,{
    init=false,
    mpid=null,
    mref=null
}).

-define(QUEUE_SIZE,5).
-define(PROC_SLEEP,10000).


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
           {From,state}->From ! State;
           {From,Message}-> MPid ! {request,{From,Message}};
                
            {'DOWN',MRef,process,MPid,_}-> {NewMPid,NewMRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
                                            server(State#sstate{mpid=NewMPid,mref=NewMRef});
            _ ->exit(invalid_message)
                                    
    end.
  

getWorkerState(MPid)-> 
    MPid ! {{server,self()},workerstate},
    State=receive
            {WPid,Free}->{WPid,Free}
          end,
    State.


monitor(MState=#monstate{wpid=_,wref=_,init=I}) when I=:= false ->
    {WorkerPid,WorkerRef}=createProcess({?MODULE,worker,self()}),
    monitor(MState#monstate{wpid=WorkerPid,wref=WorkerRef,init=true});

monitor(MState=#monstate{wpid=W,free=F,wref=Ref})->
    receive

        {From,isFree}->From !{workerstate,F};
        {request,{From ,Message}} -> case getWorkerState(self()) of
                                        {_,true}-> W ! {From,Message},
                                                   monitor(MState#monstate{free=false});
                                        {_,false}-> From ! {worker_busy,"try later"},
                                                   monitor(MState)
                                     end;


        {worker,{starting,_}}->monitor(MState#monstate{free=false});

        {worker,{finished,_}}->monitor(MState#monstate{free=true});

        {'DOWN',Ref,process,_,_}->
             {NewWorkerPid,NewWorkerRef}=createProcess({?MODULE,worker,self()}),
             monitor(MState#monstate{wpid=NewWorkerPid,wref=NewWorkerRef,free=true});

        _->exit(invalid_message)

    end.

worker(MPid)->
    receive 
        {From,MSG} ->
            MPid! {worker,{starting,MSG}},
            timer:sleep(?PROC_SLEEP),
            From ! {processed,MSG},
            MPid ! {worker,{finished,MSG}},
            worker(MPid);
        _ ->exit(bad_msg)
    end.

