defmodule WhalewatchApp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :whalewatch_app,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WhalewatchApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:csv, "~> 1.2.3"},
      {:bamboo, "~> 1.0"},
      {:bamboo_smtp, "~> 1.6.0"},
      {:cowboy, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:phauxth, "~> 1.2"},
      {:oauther, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:ecto_enum, "~> 1.0"},
      {:phoenix, "~> 1.3.4"},
      {:httpoison, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:websockex, "~> 0.4.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:bcrypt_elixir, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:crypto_compare, git: "https://github.com/agilealpha/crypto_compare"},
      {:mox, "~> 0.3", only: :test},
      {:number, "~> 0.5.6"},
      {:excoveralls, "~> 0.4"},
      {:extwitter, "~> 0.8"},
      {:phoenix_active_link, "~> 0.1.1"},
      {:scrivener_ecto, "~> 1.3"},
      {:scrivener_html, "~> 1.7"},
      {:timex, "~> 3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test --no-start"]
    ]
  end
end
