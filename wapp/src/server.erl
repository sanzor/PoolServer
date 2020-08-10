-module(server).
-behaviour(gen_server).
-include("records.hrl").
-export([start_link/1,init/1,handle_cast/2,handle_info/2,handle_call/3]).
-define(SERVER,?MODULE).
-define(QMAX,3).
start_link()->
    {ok,Pid}=gen_server:start_link({local,?SERVER},?SERVER,[],[]),
    {ok,Pid}.

init()->
    {ok,#state{wmap=dict:new()}}.
handle_cast({From,Message},State=#state{queue=Q,qc=Cnt})when Cnt>?QMAX  ->
    From ! {server,overflow,Message},
    {noreply,State}.
handle_cast({From,Message},State=#state{queue=Q,qc=Cnt,wmap=Map})->
     
    {noreply,State}.

handle_call(Request,From,State)->
    Response=sugi,
    {reply,Response,State}.

handle_info({'DOWN',Ref,process,Pid,Reason},State)->
    Newdict=dict:erase(Ref),
    {noreply,State#state{wmap=NewDict}};
handle_info(Message,State)->
    {ok,State}.

terminate(Reason,State)->
    {ok,State}.


