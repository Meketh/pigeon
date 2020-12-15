defmodule Swarm.Agent.Test do
  use Test.Case, subject: Swarm.Agent

  test "replicate" do
    id = :replicate
    assert replicate(id, []) == {:ok, id}
    assert exists(id)
  end

  test "1 store" do
    id = :store1
    assert replicate(id, [:store]) == {:ok, id}
    eventually assert get(id, []) == %{store: %{}}
    assert get(id, [:store]) == %{}
  end

  test "3 store" do
    id = :store3
    assert replicate(id, [:a, :b, :c]) == {:ok, id}
    assert get(id, []) == %{a: %{}, b: %{}, c: %{}}
    assert get(id, [:a]) == %{}
    assert get(id, [:b]) == %{}
    assert get(id, [:c]) == %{}
  end

  test "set" do
    id = :set
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x, :a], 333) == :ok
    assert get(id, [:x, :a]) == 333
    assert set(id, [:x, :b], 666) == :ok
    assert get(id, [:x, :b]) == 666
    assert set(id, [:x, :a], 999) == :ok
    assert get(id, [:x, :a]) == 999
    assert get(id, [:x]) == %{a: 999, b: 666}
  end

  test "update" do
    id = :update
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x, :a], 333) == :ok
    assert get(id, [:x, :a]) == 333
    assert update(id, [:x, :a], &(&1 + 333)) == :ok
    assert get(id, [:x, :a]) == 666
    assert update(id, [:x, :a], {Kernel, :+, [111]}) == :ok
    assert get(id, [:x, :a]) == 777
  end

  test "update_in" do
    id = :update_in
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x], %{a: %{b: %{c: 333}}}) == :ok
    assert update(id, [:x, :a, :b, :c], {Kernel, :+, [111]}) == :ok
    assert get(id, [:x, :a, :b, :c]) == 444
    assert set(id, [:x, :a, :b, :c], 555) == :ok
    assert get(id, [:x, :a, :b, :c]) == 555
  end

  test "get_and_update" do
    id = :get_and_update
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x], %{a: %{b: %{c: 333}}}) == :ok
    assert get_and_update(id, [:x, :a], fn a ->
      {Sarasa, %{z: a.b, x: a.b.c * 2}}
    end) == Sarasa
    new_a = %{z: %{c: 333}, x: 666}
    assert get(id, [:x, :a]) == new_a
    assert get_and_update(id, [:x], fn x -> {:ok, %{b: x.a}} end) == :ok
    assert get(id, [:x]) == %{a: new_a, b: new_a}
    assert get_and_update(id, [:x], fn x ->
      {x.b.z.c - x.b.x, %{a: nil, b: nil, c: x.b.z.c + x.b.x}}
    end) == -333
    assert get(id, [:x]) == %{c: 999}
  end


  test "cast" do
    id = :cast
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x, :a], 333) == :ok
    assert get(id, [:x, :a]) == 333
    assert cast(id, [:x, :a], &(&1 + 333)) == :ok
    eventually assert get(id, [:x, :a]) == 666
    assert cast(id, [:x, :a], {Kernel, :+, [111]}) == :ok
    eventually assert get(id, [:x, :a]) == 777
  end

  test "cast_in" do
    id = :cast_in
    assert replicate(id, [:x]) == {:ok, id}
    assert set(id, [:x], %{a: %{b: %{c: 333}}}) == :ok
    assert cast(id, [:x, :a, :b, :c], {Kernel, :+, [111]}) == :ok
    eventually assert get(id, [:x, :a, :b, :c]) == 444
  end
end
