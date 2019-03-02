# WhalewatchApp

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Testing the data model

* Run the migrations
* Run the seeds ``` mix run priv/repo/seeds.exs ```
* Run the sql seeds ``` psql whalewatch_app_dev < priv/repo/seeds.sql ```
* Run the load test alerts ``` psql whalewatch_app_dev < priv/repo/load.sql ```
* Run the alerts ``` psql whalewatch_app_dev < priv/repo/alerts.sql ```


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
