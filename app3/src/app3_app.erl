%%%-------------------------------------------------------------------
%% @doc app3 public API
%% @end
%%%-------------------------------------------------------------------

-module(app3_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok,Root}=app3sup:start_link(),
    register(_StartArgs,Root),
    ok.
    

stop(_State) ->
    ok.

%% internal functions
