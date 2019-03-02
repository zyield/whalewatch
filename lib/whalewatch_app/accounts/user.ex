defmodule WhalewatchApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhalewatchApp.Accounts.User
  alias WhalewatchApp.Alerts.Alert
  alias WhalewatchApp.Notifications.Notification

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime
    field :sessions, {:map, :integer}, default: %{}

    field :password, :string, virtual: true
    field :new_password, :string, virtual: true
    field :new_password_confirmation, :string, virtual: true

    has_many :alerts, Alert
    has_many :notifications, Notification

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_email
  end

  def onboarding_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> unique_email 
    |> validate_password(:password)
    |> put_pass_hash
  end

  def update_password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:new_password, :new_password_confirmation])
    |> validate_required([:new_password, :new_password_confirmation])
    |> validate_password(:new_password)
    |> validate_password_confirmation(attrs)
    |> put_pass_hash
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_email
    |> validate_password(:password)
    |> put_pass_hash
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  defp validate_password_confirmation(changeset, %{ "new_password" => new_pass, "new_password_confirmation" => new_pass_confirmation }) do
    case new_pass === new_pass_confirmation do
      true -> 
        changeset
        |> change(password: new_pass)
      false ->
        changeset
        |> add_error(:password, "confirmation does not match.")
    end 
  end

  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Argon2 or Pbkdf2, change Bcrypt to Argon2 or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
    %{password: password}} = changeset) do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}
end
