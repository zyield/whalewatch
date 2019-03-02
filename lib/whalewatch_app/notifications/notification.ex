defmodule WhalewatchApp.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias WhalewatchApp.Accounts.User

  schema "notifications" do
    field :from, :binary
    field :to, :binary
    field :to_name, :string
    field :from_name, :string
    field :cents_value, :integer
    field :token_amount, :integer
    field :symbol, :string
    field :hash, :binary

    belongs_to :user, User

    timestamps()
  end

  def changeset(notification, attrs \\ %{}) do
    notification
    |> cast(attrs, [:from, :to, :from_name, :to_name, :symbol, :cents_value, :token_amount, :user_id, :hash])
  end

end
