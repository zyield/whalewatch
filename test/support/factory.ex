defmodule WhalewatchApp.Factory do
  use ExMachina.Ecto, repo: WhalewatchApp.Repo

  alias WhalewatchApp.Accounts.User
  alias WhalewatchApp.Wallets.Wallet
  alias WhalewatchApp.Alerts.Alert
  alias WhalewatchApp.Tokens.Token
  alias WhalewatchApp.Blocks.Block

  def user_factory do
    %User{
      email: "john.doe@example.com"
    }
  end

  def wallet_factory do
    %Wallet{
      name: "Binance",
      address: "0xfe9e8709d3215310075d67e3ed32a380ccf451c8",
      type: :eth
    }
  end

  def alert_factory do
    %Alert{
      symbol: "POLY",
      contract_address: "0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec",
      threshold: 500_000,
      user: build(:user),
      wallets: [],
      type: :erc20,
      status: :active
    }
  end

  def token_factory do
    %Token{
      symbol: "CMCT",
      contract_address: "0x123",
      decimals: 18,
      type: :erc20,
      name: "Crowd Machine"
    }
  end

  def block_factory do
    %Block{
      hash: "0x00",
      number: 1
    }
  end
end
