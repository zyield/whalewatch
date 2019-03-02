defmodule WhalewatchApp.Alerts.Alert do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhalewatchApp.AddressType
  alias WhalewatchApp.Accounts.User
  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Tokens
  alias WhalewatchApp.Repo

  @alerts_limit 1
  @eth_min_threshold 1_000_000_00
  @btc_min_threshold 2_500_000_00
  @erc20_min_threshold 100_000_00

  schema "alerts" do
    field :contract_address, AddressType
    field :symbol, :string
    field :threshold, :integer
    field :status, AlertStatus
    field :type, TokenType

    embeds_many :wallets, Wallet, on_replace: :delete do
      field :name, :string
      field :address, :binary
    end

    belongs_to :user, User

    timestamps()
  end

  def base_changeset(alert, attrs \\ %{}) do
    alert
    |> cast(attrs, [:symbol, :contract_address, :threshold, :type])
    |> cast_embed(:wallets, with: &wallet_changeset/2)
    |> cast_assoc(:user)
    |> validate_required([:threshold])
    |> validate_min_threshold
    |> put_contract_address
    |> put_symbol
  end

  @doc false
  def changeset(alert, attrs \\ %{}) do
    base_changeset(alert, attrs)
    |> cast(attrs, [:status])
  end

  def onboarding_changeset(alert, attrs \\ %{}) do
    alert
    |> cast(attrs, [:symbol, :contract_address, :threshold])
    |> cast_embed(:wallets, with: &wallet_changeset/2)
    |> validate_required([:threshold])
    |> validate_min_threshold
    |> put_contract_address
    |> put_symbol
  end

  defp validate_min_threshold(%Ecto.Changeset{valid?: true, changes: %{ type: :eth, threshold: threshold }} = changeset) do
    if threshold < @eth_min_threshold do
      changeset
      |> add_error(:"", "You are trying to set a threshold lower than the minimum allowed value")
    else
      changeset
    end
  end
  defp validate_min_threshold(%Ecto.Changeset{valid?: true, changes: %{ type: :btc, threshold: threshold }} = changeset) do
    if threshold < @btc_min_threshold do
      changeset
      |> add_error(:"", "You are trying to set a threshold lower than the minimum allowed value")
    else
      changeset
    end
  end
  defp validate_min_threshold(%Ecto.Changeset{valid?: true, changes: %{ threshold: threshold }} = changeset) do
    if threshold < @erc20_min_threshold do
      changeset
      |> add_error(:"", "You are trying to set a threshold lower than the minimum allowed value")
    else
      changeset
    end
  end
  defp validate_min_threshold(changeset), do: changeset

  defp put_symbol(%Ecto.Changeset{valid?: true, changes: %{ type: :eth }} = changeset) do
    changeset
    |> change(%{ symbol: "ETH" })
  end
  defp put_symbol(%Ecto.Changeset{valid?: true, changes: %{ type: :btc }} = changeset) do
    changeset
    |> change(%{ symbol: "BTC" })
  end
  defp put_symbol(changeset), do: changeset

  defp put_contract_address(%Ecto.Changeset{valid?: true, changes: %{ type: :btc }} = changeset) do
    changeset
    |> change(%{contract_address: ""})
  end
  defp put_contract_address(%Ecto.Changeset{valid?: true, changes: %{ symbol: nil }} = changeset) do
    changeset
      |> change(%{contract_address: "" })
  end
  defp put_contract_address(%Ecto.Changeset{valid?: true, changes: %{ symbol: symbol }} = changeset) do
    with {:ok, token } <- Tokens.get_by_symbol(symbol) do
      changeset
      |> change(%{contract_address: token.contract_address})
    else
      _error ->
        changeset
        |> add_error(:symbol, "does not exist in our system")
    end
  end
  defp put_contract_address(changeset), do: changeset

  defp wallet_changeset(schema, params) do
    schema
    |> cast(params, [:name, :address])
  end
end
