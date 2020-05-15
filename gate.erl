-module(gate).
-behaviour(gen_server).
-compile(export_all).
-record(gst,#{
    sup,
    refs
}).

process(Message,Server)->
    gen_server:call(Server,Message).


start(Sup)->
    gen_server:start({local,?MODULE},?MODULE,[Sup]).
start_link(Sup)->
   gen_server:start_link({local,?MODULE},?MODULE,[Sup]).

init(Sup)->
    {ok,#state{sup=Sup,refs=gb_sets:new()}}.

handle_call(From,Message)->
    
%api




%handlers