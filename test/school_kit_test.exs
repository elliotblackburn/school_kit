defmodule SchoolKitTest do
  use ExUnit.Case
  doctest SchoolKit

  test "greets the world" do
    assert SchoolKit.hello() == :world
  end
end
