%%%-------------------------------------------------------------------
%% @doc simple public API
%% @end
%%%-------------------------------------------------------------------

-module(simple_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    proc:loop().

stop(_State) ->
    ok.

%% internal functions
