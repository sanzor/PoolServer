-module(wk).
-behaviour(gen_server).
-compile(export_all).


-record(state,{
   limit,
   processed=[]
}).
start_link(Limit)->
   gen_server:start_link(?MODULE, Limit, []).
    
start(Limit)->
    gen_server:start(?MODULE,Limit,[]).
init(Limit)->
    State=#state{limit=Limit},
    {ok,State}.


handle_call(From,Message,State=#state{processed=P,limit=L})->
    Reply={{processed,self(),os:timestamp()},Message},
    {reply,Reply,State#state{limit=L+1,processed=[Message,P]}}.


    


