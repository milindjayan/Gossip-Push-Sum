defmodule Gossip.Start do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
    check_time(System.os_time(:millisecond))
  end

  def check_time(start_time) do
    end_time = System.os_time(:millisecond)
    time = end_time - start_time
    if(time<=2000000) do
      check_time(start_time)
    else
      IO.puts "Convergence could not be reached within 2000000ms"
      System.halt(1)
    end
  end

  def init({num_of_nodes, topology, start_time}) do
    Process.send_after(self(), :start, 0)
    {:ok, {num_of_nodes, topology, [], start_time}}
  end

  def get_state() do
    GenServer.call(__MODULE__,:getState)
  end

  def delete_pid(pid) do
    GenServer.cast(__MODULE__,{:done,pid})
  end

  def handle_info(:start, {node_count, topology, deleted_pids, start_time}) do
    IO.inspect "Starting Gossip"
    actor_pids= Enum.map(1..node_count, fn _ -> Gossip.ActorSupervisor.add_child() end)
    Gossip.Topologies.initialise(actor_pids,topology)

    _table = :ets.new(:table, [:named_table,:public])

    #mid=Gossip.Topologies.get_mid()
    start_pid = Gossip.Topologies.start_node()

    GenServer.cast(start_pid,{:recieve})
    {:noreply, {node_count, topology, deleted_pids, start_time}}
  end

  def handle_call(:getState,_from,state) do
    {:reply,state,state}
  end

  def handle_cast({:done, pid}, {node_count, topology, deleted_pids, start_time}) do
    :ets.insert(:table,{pid,:removed})
    check_count=trunc(node_count*0.9)
    deleted_pids=deleted_pids ++ [pid]
    # IO.puts("Length deleted pids:")
    # IO.inspect(length(deleted_pids))
    # IO.puts("NOde Count:")
    # IO.inspect(node_count)
    if(length(deleted_pids) >= check_count) do
      IO.puts("Time taken:")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.inspect(time_taken)
      System.halt(1)
    end

    {:noreply, {node_count, topology, deleted_pids, start_time}}
  end

end
