-module(wk).
-behaviour(gen_server).
-compile(export_all).


-record(state,{
    ref,
    limit,
    count=0,
    toSend
}).
start_link(ToSend,Ref,Limit)->
   gen_server:start_link(?MODULE, {ToSend,Ref,Limit}, []).
    


init({ToSend,Ref,Limit})->
    State=#state{ref=Ref,toSend=ToSend,limit=Limit},
    {ok,State}.


handle_call({process,Message},From,State)->
    {reply,{processed,os:timestamp()},State};
handle_call(Message,From,State)->
     self() ! {from_call,Message},
    {noreply,State}.
handle_cast(Message,State=#state{count=C})->
    self() ! {from_cast,Message},
    {noreply,State}.

handle_info(Message,State=#state{count=C,limit=L,toSend=T})->
    T! {badrequest,Message},
    Ret=if C>L -> {stop,State};
           true ->{noreply,State#state{count=C+1}}
        end,
    Ret.
    


