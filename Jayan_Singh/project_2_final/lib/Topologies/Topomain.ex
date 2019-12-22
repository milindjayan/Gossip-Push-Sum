defmodule Gossip.Topologies do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def initialise(list, topology) do
    GenServer.cast(__MODULE__, {:initialise_topo, list, topology})
  end

  def get_all_neighbours(pid) do
    GenServer.call(__MODULE__, {:neighbours, pid})
  end

  def get_random_neighbour_push_sum(pid) do
    GenServer.call(__MODULE__,{:random_neighbour_push_sum,pid})
  end

  def get_random_neighbour(pid) do
    GenServer.call(__MODULE__, {:random_neighbour, pid},:infinity)
  end

  def get_random_neighbour_gossip(pid) do
    GenServer.call(__MODULE__,{:random_neighbour_gossip,pid},:infinity)
  end

  def get_mid() do
    GenServer.call(__MODULE__, :get_mid)
  end

  def start_node() do
    GenServer.call(__MODULE__,:start_node,:infinity)
  end

  def get_state() do
    GenServer.call(__MODULE__,:get_state)
  end

  def getRandomAliveNeighbour(list) do

    if(Enum.empty?(list)) do
      :false
    else
      neighbourNode=Enum.random(list)
      return_val=:ets.lookup(:table,neighbourNode)
      cond do
        Enum.empty?(return_val) ->
          neighbourNode
        true->
          getRandomAliveNeighbour(List.delete(list,neighbourNode))
      end
    end
  end

  # SERVER
  def init(:no_args) do
    {:ok, %{}}
  end

  def handle_call({:random_neighbour_push_sum,pid} ,_from, map) do
    neighbours= Map.get(map,pid)
    return_pid=Enum.random(neighbours)
    {:reply,return_pid,map}
  end

  def handle_call({:neighbours, pid}, _from, map) do
    neighbours = Map.get(map, pid)
    {:reply, neighbours, map}
  end

  def handle_call({:random_neighbour, pid}, _from, map) do
    neighbours = Map.get(map, pid)
    return_pid=getRandomAliveNeighbour(neighbours)
    {:reply, return_pid, map}
  end

  def handle_call({:random_neighbour_gossip,pid},_from,map) do
    {_, topo, _, _} = Gossip.Start.get_state()
    neighbours = Map.get(map,pid)
    return_pid=
      if topo == "full" do
        Enum.random(neighbours)
      else
        getRandomAliveNeighbour(neighbours)
      end
    {:reply,return_pid,map}
  end

  def handle_call(:get_state,_from,map) do
    {:reply,map,map}
  end

  def handle_cast({:initialise_topo, list, topology}, _map) do
    neighbours= Gossip.Topo.find_neighbours(list,topology)
    neighbours_1 = :maps.filter fn _, v -> v != [] end, neighbours
    {:noreply, neighbours_1}
  end

  def handle_call(:get_mid, _from, map) do
    pids = Map.keys(map)
    middle_pid = Enum.at(pids, div(length(pids), 2))
    {:reply, middle_pid , map}
  end

  def handle_call(:start_node,_from,map) do
    pids = Map.keys(map)
    some_pid= Enum.random(pids)
    {:reply,some_pid,map}
  end
end
