# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :whalewatch_app, env: Mix.env()

# General application configuration
config :whalewatch_app,
  ecto_repos: [WhalewatchApp.Repo]

config :hackney, timeout: 150_000, max_connections: 500

# Configures the endpoint
config :whalewatch_app, WhalewatchAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HfNGvC/ypO+h+jHDbXySBnYJgFfViPYLia7YJpTA91MXujcclHDD6WgL2z3lmiNS",
  render_errors: [view: WhalewatchAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WhalewatchApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "iVxvbB+T",
  endpoint: WhalewatchAppWeb.Endpoint

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :scrivener_html, :view_style, :bootstrap_v4

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
