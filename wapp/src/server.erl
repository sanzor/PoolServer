-module(server).
-behaviour(gen_server).
-export([start_link/1,init/1,handle_cast/2,handle_info/2,handle_call/3,terminate/2]).

start_link(Name)->
    ServerName=list_to_atom(Name++".server"),
    {ok,Pid}=gen_server:start_link({local,ServerName},?MODULE,Name),
    register(ServerName,Pid),
    {ok,Pid}.

init(Name)->
    {ok,#state{name=Name}}.


handle_cast(Message,State)->
    {ok,State}.

handle_call(Request,From,State)->
    Response=sugi,
    {ok,Response,State}.

handle_info(Message,State)->{ok,State}.

terminate(Reason,State)->{ok,State}.