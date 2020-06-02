-module(wk).
-behaviour(gen_server).
-compile(export_all).


-record(state,{
   queue,
   queueCount,
   processedCount
}).

-define(MAX_PROCESSED,1000).
-define(QUEUE_SIZE,10).

start_link()->
   gen_server:start_link(?MODULE, [], []).
    
start()->
    gen_server:start(?MODULE,[],[]).
init([])->
    {ok,#state{queue=queue:new(),queueCount=0,processedCount=0}}.


handle_call(state,From,State)->
    {reply,State,State};
handle_call(Message,From,State=#state{counter=C,depreciation=D,queueSize=S})when -> 
     {}
handle_call(Message,From,State=#state{processed=P,counter=C,depreciation=D})->
     Reply=if C=:=L;C>L -> exit({limit_reached,{toProcess,Message}});
              C<L       -> {{processed,self(),os:timestamp()},Message}
     end,
    {reply,Reply,State#state{counter=C+1,processed=[Message|P]}}.


handle_info(Message,State=#state{unknown=U})->
    {noreply,State#state{unknown=[Message|U]}}.








    


