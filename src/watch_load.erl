-module(watch_load).
-export([start_loop/1, start_loop/0]).
-export([loop_loading/2, loop_quering/1]).
-define(INTERVAL, 1000).
-include_lib("eunit/include/eunit.hrl").

get_module_name_from_beam({_Path, Base}) ->
    Name = re:replace(Base, "(\\w+)[.]beam$", "\\g1", [{return, list}]),
    list_to_atom(Name).

get_mtime({Path, Base}) ->
    {ok, FileInfo} = file:read_file_info(filename:join(Path, Base)),
    Mtime = lists:nth(6, tuple_to_list(FileInfo)),
    calendar:datetime_to_gregorian_seconds(Mtime).

load_beams_acc([], LoadedModules) ->
    LoadedModules;
load_beams_acc([Beam | Beams], LoadedModules) ->
    Name = get_module_name_from_beam(Beam),
    case proplists:get_value(Name, LoadedModules) of
        undefined ->
            case code:is_loaded(Name) of
                false ->
                    {module, Name} = code:load_file(Name),
                    load_beams_acc(Beams, [{Name, get_mtime(Beam)} | LoadedModules]);
                _ ->
                    true = code:soft_purge(Name),
                    {module, Name} = code:load_file(Name),
                    load_beams_acc(Beams, [{Name, get_mtime(Beam)} | LoadedModules])
            end;
        OldMtime ->
            NewMtime = get_mtime(Beam),
            case NewMtime > OldMtime of
                false ->
                    load_beams_acc(Beams, LoadedModules);
                true ->
                    true = code:soft_purge(Name),
                    {module, Name} = code:load_file(Name),
                    LoadedModules2 = proplists:delete(Name, LoadedModules),
                    load_beams_acc(Beams, [{Name, NewMtime} | LoadedModules2])
            end
    end.

load_beams(Beams, LoadedModules) ->
    load_beams_acc(Beams, LoadedModules).

loop_loading(Dir, LoadedModules) ->
    receive
        try_load ->
            {ok, Beams} = file:list_dir(Dir),
            Beams2 = [{Dir, Base} || Base <- Beams],
            ?MODULE:loop_loading(Dir, load_beams(Beams2, LoadedModules))
    end.

loop_quering(Pid) ->
    Pid ! try_load,
    timer:sleep(?INTERVAL),
    ?MODULE:loop_quering(Pid).

start_loop(Dir) ->
    Pid = spawn_link(?MODULE, loop_loading, [Dir, []]),
    spawn_link(?MODULE, loop_quering, [Pid]),
    ok.

start_loop() ->
    start_loop("ebin").
