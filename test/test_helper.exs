{:ok, _ } = WhalewatchApp.Application.start(:normal, %{})

Application.ensure_all_started(:ex_machina)
Application.ensure_all_started(:mox)
Application.ensure_all_started(:hackney)

ExUnit.start(exclude: [:skip])

Ecto.Adapters.SQL.Sandbox.mode(WhalewatchApp.Repo, :manual)
