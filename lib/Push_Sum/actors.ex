defmodule PushSum.Actor do
  use GenServer

  def start_link(i) do
    GenServer.start_link(__MODULE__, i)
  end

  def init(i) do
    {:ok, {i, 1, i / 1, 0,:susceptible}}
  end

  def get_state(pid) do
    GenServer.call(pid,{:getState})
  end

  #CALLBACKS

  def handle_call({:getState},_from,state) do
    {:reply,state,state}
  end

  def handle_info(:send,{s,w,ratio,count,curr_status}) do

    state=
      cond do

        curr_status == :removed ->
          {s,w,ratio,count,curr_status}

        curr_status == :infected ->
          half_s = s / 2
          half_w = w / 2
          if half_s == 0 or half_w ==0 do
            PushSum.Start.delete_pid(self())
            {half_s,half_w,ratio,count,:removed}
          else
            random_neighbour=Gossip.Topologies.get_random_neighbour(self())
            GenServer.cast(random_neighbour,{:recieve,half_s,half_w})
            Process.send_after(self(), :send, 30)
            {half_s,half_w,ratio,count,:infected}
          end
      end
    {:noreply,state}
  end

  def handle_cast({:recieve,old_s,old_w},{s,w,ratio,count,curr_status}) do
    new_s = old_s + s
    new_w = old_w + w
    state =
      if new_s == 0 or new_w ==0 do
        PushSum.Start.delete_pid(self())
        {new_s,new_w,ratio,count,:removed}
      else
        new_ratio = new_s/new_w
        diff = abs(new_ratio-ratio)
        state=
          case curr_status do
            :susceptible ->
              Process.send_after(self(),:send, 0)
              {new_s,new_w,new_ratio,0,:infected}

            :infected ->
              if(count==2 && diff<:math.pow(10, -10)) do
                PushSum.Start.delete_pid(self())
                {new_s,new_w,new_ratio,count+1,:removed}
              else
                if(diff < :math.pow(10, -10)) do
                  {new_s,new_w,new_ratio,count+1,:infected}
                else
                  {new_s,new_w,new_ratio,0,:infected}
                end
              end

            :removed ->
              {s,w,ratio,count,curr_status}
          end
        state
      end
    {:noreply,state}
  end
end



# defmodule PushSum.Actor do
#   use GenServer

#   def start_link(i) do
#     GenServer.start_link(__MODULE__, i)
#   end

#   def init(i) do
#     {:ok, {i, 1, i / 1, 0}}
#   end

#   def get_state(pid) do
#     GenServer.call(pid,{:getState})
#   end

#   #CALLBACKS

#   def handle_call({:getState},_from,state) do
#     {:reply,state,state}
#   end

#   def handle_cast({:recieve,old_s,old_w},{s, w, ratio, times}) do
#     s = old_s + s
#     w = old_w + w
#     new_s = s / 2
#     new_w = w / 2
#     new_ratio = new_s/new_w
#     diff = abs(new_ratio,ratio)

#     times=
#       cond do
#         times ==2 and diff < :math.pow(10,-10) ->
#           stopProcess()
#           times
#         true ->
#           next_pid = get_neighbour_push_sum(self())
#           GenServer.cast(next_pid,{new_s,new_ratio})
#           if diff < :math.pow(10,-10) do
#             times+1
#           else
#             0
#           end
#       end
#     {:noreply,{new_s,new_w,new_ratio,times}}
#   end

# end
# def handle_cast({:send,old_s,old_w},{s,w,ratio,changes}) do
  #   s = s + old_s
  #   w = w + old_w
  #   s_new = s / 2
  #   w_new = w / 2
  #   new_ratio = s_new / w_new
  #   diff = new_ratio - ratio
  #   diff = abs(diff)

  #   changes =
  #     if(diff < :math.pow(10, -10) && changes == 2) do
  #       PushSum.Start.done(self())
  #       changes
  #     else
  #       next_pid = Gossip.Topologies.get_random_neighbour(self())
  #       GenServer.cast(next_pid, {:next, s_new, w_new})

  #       if(diff < :math.pow(10, -10)) do
  #         changes + 1
  #       else
  #         0
  #       end
  #     end

  #   {:noreply, {s_new, w_new, new_ratio, changes}}
  # end


