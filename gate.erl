-module(gate).
-behaviour(gen_server).
-compile(export_all).
-record(state,#{
    sup,
    refs,
    queue
}).

process(Message,Server)->
    gen_server:call(Server,Message).


start(Sup,Args)->
    gen_server:start({local,?MODULE},?MODULE,[Sup],[]).
start_link(Sup,Args)->
   gen_server:start_link({local,?MODULE},?MODULE,Args,[]).

init({Sup,N})->
    {ok,#state{sup=Sup,refs=gb_sets:new(),queue=queue:new()}}.

process(Queue,F)->
    process_internal(Queue,F,[]).

process_internal(Queue,F,Results)->
    case queue:out(Queue) of 
        {{value,V},NQ}->process_internal(NQ,F,[F(V)|Results]);
        {empty,_}->Results.


handle_call(process_all,From,State=#state{sup=Sup,refs=Refs,queue=Q})->
      F=fun(El)->{os:timestamp(),El},
      process(Q,F).
handle_cast(Message,State=#state{sup=Sup,refs=Refs})  ->
     {ok,Pid}=supervisor:start_child(Sup,[3]),
      Ref=erlang:monitor(Pid),
     {noreply,State#state{refs=gb_sets:insert(Ref,Refs)}};
handle_cast(Message,State=#state{n=N}) ->
    {noreply,State#state{quque=queue:in(Message,Q)}}.



   


  
handle_info({'DOWN',Ref,process,Pid,{limit_reached,{_,Message}},S=#state{queue=Q})->
     NewQueue=queue:in(Message,Q),
     {noreply,S#state{queue=NewQueue}}.
%api




%handlers