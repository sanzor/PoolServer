-module(server).
-behaviour(gen_server).
-include("sstate.hrl").
-export([init/1,handle_call/3,handle_info/2,handle_cast/2,startall/0]).

-define(QMIN,0).
-define(QMAX,5).

startall()->
    {ok,Spid}=supervisor:start_link({local,?MODULE},[]),
    Children=queue:from_list([Pid|| Pid<-lists:map(fun(_)->supervisor:start_child(Spid,lists:seq(?QMIN,startLimit)) end)]),
    State=#sstate{startLimit=?QMIN,stopLimit=?QMAX,spid=Spid,queue=Children},
    {ok,Pid}=gen_server:start_link({local,?MODULE},?MODULE,[State]),
    Pid.

init(State)->
    {ok,State}.


handle_call(state,_,State)->
    {reply,State,State}.

handle_cast({req,_},State) ->
    {noreply,State}.

handle_info(_,State)->
    {noreply,State};
handle_info({'DOWN',Ref,process,Pid,Reason},State)->
