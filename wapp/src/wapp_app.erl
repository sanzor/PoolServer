%%%-------------------------------------------------------------------
%% @doc app3 public API
%% @end
%%%-------------------------------------------------------------------

-module(wapp).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
   rootsup:start_link().
    

stop(_State) ->
    ok.

%% internal functions
