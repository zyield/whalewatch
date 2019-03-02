defmodule WhalewatchAppWeb.Router do
  use WhalewatchAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
  end

  scope "/", WhalewatchAppWeb do
    pipe_through :browser

    get "/wallets", WalletController, :index

    get "/", OnboardingController, :new

    get "/register", UserController, :new
    get "/login", SessionController, :new
    get "/password_reset", PasswordResetController, :new
    get "/confirm", ConfirmController, :index
    get "/password_resets/edit", PasswordResetController, :edit
    get "/confirm/new", ConfirmController, :new
    post "/confirm", ConfirmController, :create
    put "/password_resets/update", PasswordResetController, :update

    get "/terms-conditions", PageController, :terms
    get "/privacy-policy", PageController, :privacy

    resources "/alerts", AlertController, except: [:show]
    resources "/users", UserController, only: [:new, :create, :update, :edit, :delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    resources "/onboarding", OnboardingController, only: [:create]
    resources "/transactions", TransactionController, only: [:index]
  end

end
