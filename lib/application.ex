defmodule MainApp do
  use Application

  def start(_type, {numNodes, topology, algorithm, start_time}) do
    children =
      if algorithm == "gossip" do
        [
          Gossip.Topologies,
          Gossip.ActorSupervisor,
          {Gossip.Start, {numNodes, topology, start_time}}
        ]
      else
        [
          Gossip.Topologies,
          PushSum.ActorSupervisor,
          {PushSum.Start, {numNodes, topology, start_time}}
        ]
      end

    opts = [strategy: :one_for_all, name: Gvp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

