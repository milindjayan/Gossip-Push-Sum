defmodule Gossip.ActorSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :nil, name: __MODULE__)
  end

  def init(:nil) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_child() do
    {:ok,pid} = DynamicSupervisor.start_child(__MODULE__, Gossip.Actor)
    pid
  end
end

