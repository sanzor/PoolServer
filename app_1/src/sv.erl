%%% top hierarchy module serving as a dispatcher between callers and monitors
-module(sv).
-import(common,[createProcess/1]).
-include("records.hrl").
-export([server/1]).
-behaviour(application).

start(normal,_Args)->
    sv:start_link().

start_link()->
    spawn_link(?MODULE,server,[#sstate{init=false}]).

server(State=#sstate{init=I})when I=:=false ->
    {MPid,MRef}=createProcess({monitor,monitor,#monstate{init=false}}),
    server(State#sstate{init=true,mpid=MPid,mref=MRef});

server(State=#sstate{mpid=MPid,mref=MRef})->
    receive
           {From,state}->From ! State,
                            server(State);
           {From,Message}-> MPid ! {request,{From,Message}},
                            server(State);
                
            {'DOWN',MRef,process,MPid,_}-> {NewMPid,NewMRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
                                            server(State#sstate{mpid=NewMPid,mref=NewMRef});
            _ ->exit(invalid_message)
                                    
    end.
  

