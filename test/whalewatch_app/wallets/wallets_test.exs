defmodule WhalewatchApp.WalletsTest do
  use WhalewatchApp.DataCase

  alias WhalewatchApp.Wallets

  describe "wallets" do
    alias WhalewatchApp.Wallets.Wallet

    @valid_attrs_exchange %{ name: "Binance", address: "0x134d4442f311f795ab7d218da300a9AE6d5F5705", type: :eth }
    @valid_attrs %{ address: "0x134d4442f311f795ab7d218da300a9AE6d5F5705", type: :erc20 }
    @update_attrs %{ name: "Binance2" }
    @invalid_attrs %{ name: "Binance", address: nil }


    def wallet_exchange_fixture(attrs \\ %{}) do
      {:ok, wallet } =
        attrs
        |> Enum.into(@valid_attrs_exchange)
        |> Wallets.create_wallet()

      wallet
    end

    def wallet_fixture(attrs \\ %{}) do
      {:ok, wallet } =
        attrs
        |> Enum.into(@valid_attrs)
        |> Wallets.create_wallet()

      wallet
    end

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_exchange_fixture()
      assert Wallets.list_wallets() == [wallet]
    end

    test "get_wallet/1 returns the wallet with a given id" do
      wallet = wallet_fixture()
      assert Wallets.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates an exchange wallet" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs_exchange)
      assert wallet.name == "Binance"
      assert wallet.address == "0x134d4442f311f795ab7d218da300a9ae6d5f5705"
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      assert {:ok, wallet} = Wallets.update_wallet(wallet, @update_attrs)
      assert %Wallet{} = wallet
      assert wallet.name == "Binance2"
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_wallet(wallet, @invalid_attrs)
      assert wallet == Wallets.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Wallets.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Wallets.get_wallet!(wallet.id) end
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Wallets.change_wallet(wallet)
    end
  end
end
