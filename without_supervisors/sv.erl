%%% top hierarchy module serving as a dispatcher between callers and monitors
-module(sv).
-import(common,[createProcess/1]).
-include("records.hrl").
-export([start/0,server/1]).



start()->
    spawn(?MODULE,server,[#sstate{init=false}]).

server(State=#sstate{init=I})when I=:=false ->
    {MPid,MRef}=createProcess({?MODULE,monitor,#monstate{init=false}}),
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
  

