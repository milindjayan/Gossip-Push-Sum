defmodule Gossip.Topo do

  def find_neighbours(list,topo) do
    neighbours = get_neighbours(list,topo)
    Stream.with_index(neighbours, 0) |> Enum.reduce(%{}, fn({v,k}, acc)-> Map.put(acc, Enum.at(list,k), v) end)
  end

  def get_neighbours(list,topo) do

    case topo do

      "line" ->
        number_nodes=length(list)
        for i <- 0..(number_nodes-1) do
          cond do
            i == 0 -> [Enum.at(list,i+1)]
            i == number_nodes-1 -> [Enum.at(list,i-1)]
            true -> [Enum.at(list,i-1),Enum.at(list,i+1)]
          end
        end

      "full" ->
        number_nodes=length(list)
        for i <- 0..(number_nodes-1) do
          list -- [Enum.at(list,i)]
        end

      "random2D" ->
        #IO.puts("random2D")
        numNodes = length(list)
        nodes = Map.new()
        nodes =Enum.reduce(0..numNodes-1,nodes, fn x,acc->
          node = Enum.at(list,x)
          coordinates = {:rand.uniform() |> Float.round(2),:rand.uniform() |> Float.round(2)}
          Map.put(acc,node,coordinates)
        end)

        nodelist = Map.keys(nodes)
        Enum.map(nodelist, fn(x) ->
          {nodeX,nodeY} = Map.fetch!(nodes,x)
          neighbour = Enum.map(nodelist,fn(y) ->
            {neighbourX,neighbourY} = Map.fetch!(nodes, y)
            distance = :math.sqrt((:math.pow(nodeX - neighbourX, 2)) + (:math.pow(nodeY - neighbourY, 2)))
            if(distance > 0 && distance < 0.1) do
              y
            end
          end)
        Enum.reject(neighbour, &is_nil/1)
      end)

      "torus" ->
        ncount = length(list)
        rowNodeCount = round(Float.ceil(:math.pow(ncount,(1/3))))
        plainNodeCount = round(:math.pow(rowNodeCount,2))
        numofNodes = round(:math.pow(rowNodeCount,3))
        Enum.map(1..ncount, fn x->
          positiveX = if(x+1 <= numofNodes && rem(x,rowNodeCount) != 0 ) do x+1 else x-rowNodeCount+1 end
          negativeX = if(x-1 >= 1 && rem(x-1,rowNodeCount) != 0) do x-1 else x+rowNodeCount-1 end
          positiveY = if(rem(x,plainNodeCount) != 0 && plainNodeCount - rowNodeCount >= rem(x,(plainNodeCount))) do x+ rowNodeCount else x-plainNodeCount+rowNodeCount end
          negativeY = if((plainNodeCount - rowNodeCount*(rowNodeCount-1)) < rem(x-1,(plainNodeCount)) + 1) do x- rowNodeCount else x+plainNodeCount-rowNodeCount end
          positiveZ = if(x+ plainNodeCount <= numofNodes) do x+ plainNodeCount else x - plainNodeCount*(rowNodeCount-1) end
          negativeZ = if(x- plainNodeCount >= 1) do x- plainNodeCount else x + plainNodeCount*(rowNodeCount-1) end
          #neighbour = [positiveX,negativeX,positiveY,negativeY,positiveZ,negativeZ]

            neighbour = [
            Enum.at(list, positiveX-1) ,
            Enum.at(list, negativeX-1) ,
            Enum.at(list, positiveY-1) ,
            Enum.at(list, negativeY-1) ,
            Enum.at(list, positiveZ-1) ,
            Enum.at(list, negativeZ-1) ]

          # Enum.filter(neighbour, fn x -> x <= ncount end)
            Enum.reject(neighbour,&is_nil/1)
        end)

      "honeycomb" ->
        number_nodes = length(list)
        check_nodes = number_nodes - rem(number_nodes,6)
        n_nodes=if(rem(round(check_nodes/6),6)==1, do: check_nodes-6, else: check_nodes)
        for i <- 0..(n_nodes-1) do

          cond do

            rem(i,6) == 0 ->
              cond do
                i == 0 -> [Enum.at(list,i+6)]
                i == n_nodes-6 -> [Enum.at(list,i-6),Enum.at(list,i+1)]
                rem(round(i/2),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6)]
                true -> [Enum.at(list,i-6),Enum.at(list,i+6)]
              end

            rem(i,6) == 1 ->
              #IO.puts("#{i} : #{rem(round((i-1)/6),2)}")
              cond do
                i == 1 -> [Enum.at(list,i+1),Enum.at(list,i+6)]
                i == n_nodes-5 -> [Enum.at(list,i-6),Enum.at(list,i-1)]
                rem(round((i-1)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6)]
                rem(round((i-1)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6)]
              end

            rem(i,6) == 2 ->
              #IO.puts("#{i} : #{rem(round((i-2)/6),2)}")
              cond do
                i == 2 -> [Enum.at(list,i-1),Enum.at(list,i+6)]
                i == n_nodes-4 -> [Enum.at(list,i-6),Enum.at(list,i+1)]
                rem(round((i-2)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6)]
                rem(round((i-2)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6)]
              end

            rem(i,6) == 3 ->
              cond do
                i == 3 -> [Enum.at(list,i+1),Enum.at(list,i+6)]
                i == n_nodes-3 -> [Enum.at(list,i-6),Enum.at(list,i-1)]
                rem(round((i-3)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6)]
                rem(round((i-3)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6)]
              end

            rem(i,6) == 4 ->
              cond do
                i == 4 -> [Enum.at(list,i-1), Enum.at(list,i+6)]
                i == n_nodes-2 -> [Enum.at(list,i-6),Enum.at(list,i+1)]
                rem(round((i-4)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6)]
                rem(round((i-4)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6)]
              end

            rem(i,6) == 5 ->
              cond do
                i == 5 -> [Enum.at(list,i+6)]
                i == n_nodes-1 -> [Enum.at(list,i-6),Enum.at(list,i-1)]
                rem(round((i-5)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6)]
                rem(round((i-5)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+6)]
              end
          end
        end

      "honeycombrandom" ->
        number_nodes = length(list)
        check_nodes = number_nodes - rem(number_nodes,6)
        n_nodes=if(rem(round(check_nodes/6),6)==1, do: check_nodes-6, else: check_nodes)

        for i <- 0..(n_nodes-1) do

          cond do

            rem(i,6) == 0 ->
              cond do
                i == 0 -> [Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-6 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round(i/2),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                true -> [Enum.at(list,i-6),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end

            rem(i,6) == 1 ->
              #IO.puts("#{i} : #{rem(round((i-1)/6),2)}")
              cond do
                i == 1 -> [Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-5 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-1)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-1)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end

            rem(i,6) == 2 ->
              #IO.puts("#{i} : #{rem(round((i-2)/6),2)}")
              cond do
                i == 2 -> [Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-4 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-2)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-2)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end

            rem(i,6) == 3 ->
              cond do
                i == 3 -> [Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-3 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-3)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-3)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end

            rem(i,6) == 4 ->
              cond do
                i == 4 -> [Enum.at(list,i-1), Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-2 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-4)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i+1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-4)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end

            rem(i,6) == 5 ->
              cond do
                i == 5 -> [Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                i == n_nodes-1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-5)/6),2) == 1 -> [Enum.at(list,i-6),Enum.at(list,i-1),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
                rem(round((i-5)/6),2) == 0 -> [Enum.at(list,i-6),Enum.at(list,i+6),Enum.at(list,Enum.random(0..(n_nodes-1)))]
              end
          end
        end

        _ ->
          IO.puts("Invalid Topology Selection")
    end
  end

end
