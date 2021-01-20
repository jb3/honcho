defmodule HonchoTest do
  use ExUnit.Case
  doctest Honcho

  test "greets the world" do
    assert Honcho.hello() == :world
  end
end
