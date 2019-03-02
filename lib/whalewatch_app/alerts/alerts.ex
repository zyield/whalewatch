defmodule WhalewatchApp.Alerts do
  @callback list_eth_alerts(integer(), String.t(), String.t()) :: [map()]
  @callback list_btc_alerts(integer(), String.t(), String.t()) :: [map()]
  @callback list_token_alerts(integer(), String.t(), String.t(), String.t()) :: [map()]
  @callback list_alerts() :: [map()]

  @moduledoc """
  The Alerts context.
  """

  import Ecto.Query, warn: false
  alias WhalewatchApp.Repo

  alias WhalewatchApp.Alerts.Alert
  alias WhalewatchApp.Accounts.User

  def activate_user_alerts(user_id) do
    from(alert in Alert,
      where: alert.user_id == ^user_id
    )
    |> Repo.update_all(set: [status: :active])
  end

  @doc """
  Returns a list of alerts for ETH transfers given:
  - value
  - from
  - to
  """
  def list_eth_alerts(cents_value, from, to) do
    from(alert in Alert,
      inner_join: user in User, on: [id: user.id],
      where:
      alert.status == ^:active and
      is_nil(alert.contract_address) and
      (
        alert.threshold <= ^cents_value
        and (
          fragment("
            case when wallets::text <> '[]'::text then
              (wallets::jsonb @> ?::jsonb or wallets::jsonb @> ?::jsonb)
            else true
            end", ^[%{address: from}], ^[%{address: to}])
        )
      ),
      distinct: alert.id
    )
    |> Repo.all
    |> Repo.preload([:user])
  end

  @doc """
  Returns a list of alerts for BTC transfers given:
  - value
  - from
  - to
  """
  def list_btc_alerts(cents_value, from, to) do
    from(alert in Alert,
      inner_join: user in User, on: [id: user.id],
      where:
      alert.status == ^:active and
      alert.symbol == "BTC"
      and (
        alert.threshold <= ^cents_value
        and (
          fragment("
            case when wallets::text <> '[]'::text then
              (wallets::jsonb @> ?::jsonb or wallets::jsonb @> ?::jsonb)
            else true
            end", ^[%{address: from}], ^[%{address: to}])
        )
      ),
      distinct: alert.id
    )
    |> Repo.all
    |> Repo.preload([:user])
  end

  @doc """
  Returns a list of alerts for token transactions given:
  - value
  - from
  - to
  - contract address
  """
  def list_token_alerts(_cents_value, _from, _to, nil), do: IO.puts "[*] contract address is nil"
  def list_token_alerts(cents_value, from, to, contract_address) do
    from(alert in Alert,
      inner_join: user in User, on: [id: user.id],
      where:
      alert.status == ^:active and
      alert.contract_address == ^contract_address and
      (
        alert.threshold <= ^cents_value
        and (
          fragment("
            case when wallets::text <> '[]'::text then
              (wallets::jsonb @> ?::jsonb or wallets::jsonb @> ?::jsonb)
            else true
            end", ^[%{address: from}], ^[%{address: to}])
        )
      ),
      distinct: alert.id
    )
    |> Repo.all
    |> Repo.preload([:user])
  end

  @doc """
  Returns the list of alerts.

  ## Examples

      iex> list_alerts()
      [%Alert{}, ...]

  """
  def list_alerts do
    Repo.all(Alert)
  end
  def list_alerts(%{ preload: associations }) do
    list_alerts()
    |> Repo.preload(associations)
  end

  def user_alerts(user) do
    from(alert in Alert,
      where: alert.user_id == ^user.id
    )
  end

  def list_user_alert_symbols(user) do
    from(alert in user_alerts(user),
      select: alert.symbol,
      distinct: alert.symbol
    )
    |> Repo.all 
  end

  @doc """
  Gets a single alert.

  Raises `Ecto.NoResultsError` if the Alert does not exist.

  ## Examples

      iex> get_alert!(123)
      %Alert{}

      iex> get_alert!(456)
      ** (Ecto.NoResultsError)

  """
  def get_alert!(id), do: Repo.get!(Alert, id)
  def get_alert!(id, %{ preload: associations }) do
    get_alert!(id)
    |> Repo.preload(associations)
  end

  @doc """
  Creates a alert.

  ## Examples

      iex> create_alert(%{field: value})
      {:ok, %Alert{}}

      iex> create_alert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_alert(attrs \\ %{}, user) do
    user
    |> Ecto.build_assoc(:alerts)
    |> Alert.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a alert.

  ## Examples

      iex> update_alert(alert, %{field: new_value})
      {:ok, %Alert{}}

      iex> update_alert(alert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_alert(%Alert{} = alert, attrs) do
    alert
    |> Alert.base_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Alert.

  ## Examples

      iex> delete_alert(alert)
      {:ok, %Alert{}}

      iex> delete_alert(alert)
      {:error, %Ecto.Changeset{}}

  """
  def delete_alert(%Alert{} = alert) do
    Repo.delete(alert)
  end

  def delete_all_for_user(user) do
    Repo.preload(user, :alerts).alerts
    |> Enum.each(&delete_alert/1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking alert changes.

  ## Examples

      iex> change_alert(alert)
      %Ecto.Changeset{source: %Alert{}}

  """
  def change_alert(%Alert{} = alert) do
    Alert.changeset(alert)
    |> Ecto.Changeset.put_embed(:wallets, alert.wallets)
  end
end
