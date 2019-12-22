defmodule Gossip.Actor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :nil)
  end

  def init(:nil) do
    {:ok, {0,:susceptible}}
  end

  def update_neighbours(list) do
    GenServer.cast(self(),{:neighboursList, list})
  end

  def get_state(pid) do
    GenServer.call(pid,{:getState})
  end

  #CALLBACKS

  def handle_call({:getState},_from,state) do
    {:reply,state,state}
  end

  def handle_info(:send,state) do
    {count,curr_status} = state
    state=
      cond do
        curr_status == :removed ->
          {count,:removed}
        # curr_status == :infected ->
        #   random_neighbour=Gossip.Topologies.get_random_neighbour(self())
        #   if random_neighbour != :false do
        #     GenServer.cast(random_neighbour,{:recieve})
        #   end
        #   Process.send_after(self(), :send, 10)
        #   {count,:infected}
        curr_status == :infected ->
          random_neighbour=Gossip.Topologies.get_random_neighbour_gossip(self())
          cond do
            random_neighbour != :false ->
              GenServer.cast(random_neighbour,{:recieve})
              Process.send_after(self(), :send, 10)
              {count,:infected}
            random_neighbour == :false ->
              Gossip.Start.delete_pid(self())
              {count,:removed}
          end
      end
    {:noreply,state}
  end

  def handle_cast({:recieve},state) do
    {count,curr_status} = state
    count=count+1
    state=
      case curr_status do
        :susceptible ->
          Process.send_after(self(), :send, 0)
          {count,:infected}

        :infected ->
          if count==10 do
            Gossip.Start.delete_pid(self())
            {count,:removed}
          else
            {count,:infected}
          end

        :removed ->
          {count,:removed}
      end
    {:noreply,state}
  end

  def handle_cast({:neighboursList,list}, state) do
    [count,condition,blist]=state
    state=[count,condition,list++blist]
    {:noreply, state}
  end
end


