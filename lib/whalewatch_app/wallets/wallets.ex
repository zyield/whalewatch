defmodule WhalewatchApp.Wallets do
  import Ecto.Query, warn: false
  alias WhalewatchApp.{Wallets.Wallet, Repo}

  @doc """
  Creates a wallet.

  ## Examples

      iex> create_wallet(%{field: value})
      {:ok, %Wallet{}}

      iex> create_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns a list of wallet addresses given a name
  """
  def list_for_name_and_type(name, type) do
    type = case type do
      :erc20 -> :eth
      "erc20" -> :eth
      _ -> type
    end

    from(wallet in Wallet,
      where: wallet.name == ^name and wallet.type == ^type,
      select: %{ "name" => wallet.name, "address" => wallet.address }
    )
    |> Repo.all 
  end

  def list_wallets_query do
    from(wallet in Wallet,
      order_by: [asc: wallet.name],
      distinct: wallet.name
    )
  end

  @doc """
  Returns the list of wallets.

  ## Examples

      iex> list_wallets()
      [%Wallet{}, ...]

  """
  def list_wallets do
    list_wallets_query()
    |> Repo.all
  end

  def list_wallets(type) do
    type = case type do
      "erc20" -> :eth
      _ -> type
    end

    from(wallet in list_wallets_query(),
      where: wallet.type == ^type
    )
    |> Repo.all
  end

  @doc """
  Gets a single wallet.

  Raises `Ecto.NoResultsError` if the Wallet does not exist.

  ## Examples

      iex> get_wallet!(123)
      %Wallet{}

      iex> get_wallet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  def get_by_address(address) do
    case Repo.get_by(Wallet, address: address) do
      nil -> {:error, nil}
      wallet -> {:ok, wallet}
    end
  end

  @doc """
  Updates a wallet.

  ## Examples

      iex> update_wallet(wallet, %{field: new_value})
      {:ok, %Wallet{}}

      iex> update_wallet(wallet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wallet(%Wallet{} = wallet, attrs) do
    wallet
    |> Wallet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Wallet.

  ## Examples

      iex> delete_wallet(wallet)
      {:ok, %Wallet{}}

      iex> delete_wallet(wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wallet changes.

  ## Examples

      iex> change_wallet(wallet)
      %Ecto.Changeset{source: %Wallet{}}

  """
  def change_wallet(%Wallet{} = wallet) do
    Wallet.changeset(wallet, %{})
  end
end
