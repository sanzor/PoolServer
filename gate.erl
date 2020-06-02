-module(gate).
-behaviour(gen_server).
-compile(export_all).
-record(state,#{
    sup,
    refs,
    queue,
    queueSize
}).
-define(LIMIT,300).

process(Message,Server)->
    gen_server:call(Server,Message).


start(Args)->
    gen_server:start({local,?MODULE},?MODULE,Args,[]).
start_link(Sup,Args)->
    gen_server:start_link({local,?MODULE},?MODULE,Args,[]).

init({Sup,QueueSize})->
    {ok,#state{queueSize=QueueSize,sup=Sup,refs=gb_sets:new(),queue=queue:new()}}.

process(Queue,F)->
    process_internal(Queue,F,[]).

process_internal(Queue,F,Results)->
    case queue:out(Queue) of 
        {{value,V},NQ}->process_internal(NQ,F,[F(V)|Results]);
        {empty,_}->Results.


handle_call(process_all,From,State=#state{sup=Sup,refs=Refs,queue=Q})->
      F=fun(El)->{os:timestamp(),El},
      Reply=process(Q,F),
      {reply,Reply,State};
handle_call(Message,From,State)->
       {reply,unknown,State}.
handle_cast(Message,State=#state{sup=Sup,refs=Refs})  ->
      {ok,Pid}=supervisor:start_child(Sup,[?LIMIT]),
      Ref=erlang:monitor(Pid),
      {noreply,State#state{refs=gb_sets:insert(Ref,Refs)}};
handle_cast(Message,State=#state{n=N}) ->
     {noreply,State#state{quque=queue:in(Message,Q)}}.



   


  
handle_info({'DOWN',Ref,process,Pid,{limit_reached,{_,Message}},S=#state{queue=Q})->
     NewQueue=queue:in(Message,Q),
     {noreply,S#state{queue=NewQueue}}.
%api




%handlers