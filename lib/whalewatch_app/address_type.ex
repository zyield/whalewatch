defmodule WhalewatchApp.AddressType do
  @behaviour Ecto.Type

  # The type function needs to return the data type that we want to use to store
  # our custom value at the database level.
  def type(), do: :binary

  # load converts the raw value pulled from the database into our
  # Elixir value.
  def load(""), do: {:ok, "0x0"}
  def load(address) when is_binary(address) do
    [ address | _tail ] = address
                         |> String.chunk(:printable)

    {:ok, address }
  end


  def dump(<< "0x", address::binary >>) do
    {:ok, "0x" <> String.downcase(address) }
  end

  def dump(address) do
    {:ok, address }
  end

  def cast(address) do
    dump(address)
  end
end
