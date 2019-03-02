defmodule WhalewatchApp.Transactions do
  import Ecto.Query, warn: false
  alias WhalewatchApp.Repo
  alias WhalewatchApp.Transactions.Transaction
  alias WhalewatchApp.Transactions.BtcTransaction

  def list_transactions do
    Repo.all(Transaction)
  end
  def list_btc_transactions do
    Repo.all(BtcTransaction)
  end

  def get(id), do: Repo.get(Transaction, id)

  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert!()
  end

  def create_btc_transaction(attrs) do
    %BtcTransaction{}
    |> BtcTransaction.changeset(attrs)
    |> Repo.insert!()
  end
end
