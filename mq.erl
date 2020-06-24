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
-define(PROC_SLEEP,1000).

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
           {From,Message}-> 
                MPid ! {server,self(),wstate},
                receive 
                    {_,Free} -> if  Free=:=true -> MPid ! {server,{From,Message}};
                                    true -> {From , busy}
                                end;
                    _ -> exit(invalid_monitor_message)
                end,
                server(State);

            {'DOWN',MRef,process,MPid,_}-> {NewMPid,NewMRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
                                            server(State#sstate{mpid=NewMPid,mref=NewMRef})
                                    
    end.
  


monitor(MState=#monstate{wpid=_,wref=_,init=I}) when I=:= false ->
    {WorkerPid,WorkerRef}=createProcess({?MODULE,worker,self()}),
    monitor(MState#monstate{wpid=WorkerPid,wref=WorkerRef,init=true});

monitor(MState=#monstate{wpid=W,free=F,wref=Ref})->
    receive
        {server,SPid,wstate}->SPid!{W,F};
        {server,{From,Msg}} ->
            if F=:= false -> From ! {worker_busy,"Try again later"},
                             monitor(MState);
               F=:= true ->  W ! {From,Msg},
                             monitor(MState#monstate{free=false})
            end;
        {worker,finished,_}->monitor(MState#monstate{free=true});

        {'DOWN',Ref,process,_,_}->
             {NewWorkerPid,NewWorkerRef}=createProcess({?MODULE,worker,self()}),
             monitor(MState#monstate{wpid=NewWorkerPid,wref=NewWorkerRef,free=true})
    end.

worker(MPid)->
    receive 
        {From,MSG} ->
            timer:sleep(?PROC_SLEEP),
            From ! {processed,MSG},
            MPid ! {worker,finished,MSG},
            worker(MPid);
        _ ->exit(bad_msg)
    end.
