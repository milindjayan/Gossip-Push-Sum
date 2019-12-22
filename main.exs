defmodule Main do

  [numNodes,topology,algorithm] =Enum.map(System.argv, (fn(x) -> x end))
  numNodes = String.to_integer(numNodes)

  start_time = System.monotonic_time(:millisecond)
  MainApp.start(:normal,{numNodes,topology, algorithm, start_time})
end

