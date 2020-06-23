-module(mq).
-compile(export_all).

-record(monstate,{
    wpid,
    free=true,
    wref
}).
-record(sstate,{
    mpid=null,
    mref=null,
    queue,
    queueCount
}).
-define(QUEUE_SIZE,5).
-define(PROC_SLEEP,1000).

start()->
    spawn(?MODULE,server,#{queue=queue:new()}).



server(State=#sstate{})->
    receive
        {From,Message}->
            case State#state.mpid of
                null ->
                    {MP,MR}=createMon(),
                    {WPid,Free}=MP !{server,self(),wstate},
                _ ->

            
            if Free=:=true -> WPid ! {server,{From,Message}};
               true -> {From , busy}
            end
    end.
  
    
createMon()->
   MPid=spawn(?MODULE,monitor,#monstate{wpid=null}),
   MRef=erlang:monitor(process,MPid),
   {MPid,MRef}.

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

        {'DOWN',process,_,Ref,_}->
            NewRef=erlang:monitor(NewPid=spawn(?MODULE,processor,self())),
            monitor(MState#monstate{wpid=NewPid,wref=NewRef,free=true})
    end.

processor(MPid)->
    receive 
        {From,MSG} ->
            timer:sleep(?PROC_SLEEP),
            From ! {processed,MSG},
            MPid ! {worker,finished,MSG}
    end.
