-module(gate).
-behaviour(gen_server).
-compile(export_all).
-record(gst,#{
    sup,
    refs,
    n,
    queue
}).

process(Message,Server)->
    gen_server:call(Server,Message).


start(Sup,Args)->
    gen_server:start({local,?MODULE},?MODULE,[Sup],[]).
start_link(Sup,Args)->
   gen_server:start_link({local,?MODULE},?MODULE,Args,[]).

init({Sup,N})->
    {ok,#state{sup=Sup,refs=gb_sets:new(),n=N,queue=queue:new()}}.

handle_cast(From,Message,State=#state{sup=Sup,refs=Refs,n=N}) when L>0 ->
     {ok,Pid}=supervisor:start_child(Sup,[3]),
     Ref=erlang:monitor(Pid),
     {noreply,State#state{refs=gb_sets:insert(Ref,Refs)}}.

handle_cast(From,Message,State=#state{queue=Q}) when L<=0 ->
    {noreply,State#state{quque=queue:in(Message,)}}
  
handle_info({'DOWN',Ref,process,Pid,_},State)->

%api




%handlers