%%%-------------------------------------------------------------------
%% @doc app3 public API
%% @end
%%%-------------------------------------------------------------------

-module(app3_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    app3sup:start_link().
    

stop(_State) ->
    ok.

%% internal functions
