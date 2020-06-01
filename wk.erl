-module(wk).
-behaviour(gen_server).
-compile(export_all).


-record(state,{
   limit,
   processed=[],
   unknown=[],
   counter=0
}).
start_link(Limit)->
   gen_server:start_link(?MODULE, Limit, []).
    
start(Limit)->
    gen_server:start(?MODULE,Limit,[]).
init(Limit)->
    State=#state{limit=Limit},
    {ok,State}.


handle_call(state,From,State)->
    {reply,State,State};
handle_call(Message,From,State=#state{processed=P,limit=L,counter=C})->
     Reply=if C=:=L;C>L -> exit({limit_reached,{toProcess,Message}});
              C<L       -> {{processed,self(),os:timestamp()},Message}
     end,
    {reply,Reply,State#state{counter=C+1,processed=[Message|P]}}.

handle_info(Message,State=#state{unknown=U})->
    {noreply,State#state{unknown=[Message|U]}}.








    


