use Mix.Config

config :whalewatch_app, base_url: "http://www.example.com"
config :whalewatch_app, :enable_ws_watchers, false
config :whalewatch_app, :enable_eth_watcher, false
config :whalewatch_app, :enable_price_job, false
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :whalewatch_app, WhalewatchAppWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :whalewatch_app, WhalewatchApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "whalewatch_app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :whalewatch_app, :alerts, WhalewatchApp.AlertsMock
config :whalewatch_app, :notification_message, WhalewatchApp.NotificationMessageMock
config :whalewatch_app, :notificator, WhalewatchApp.AlertFilterMock

# Comeonin password hashing test config
#config :argon2_elixir,
  #t_cost: 2,
  #m_cost: 8
config :bcrypt_elixir, log_rounds: 4
#config :pbkdf2_elixir, rounds: 1

# Mailer test configuration
config :whalewatch_app, WhalewatchApp.Mailer,
  adapter: Bamboo.TestAdapter

config :phauxth,
        log_level: false
