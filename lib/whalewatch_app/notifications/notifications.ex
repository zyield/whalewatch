defmodule WhalewatchApp.Notifications do
  import Ecto.Query, warn: false

  alias WhalewatchApp.Repo
  alias WhalewatchApp.Notifications.Notification

  def user_notifications(user) do
    from(notification in Notification,
      where: notification.user_id == ^user.id)
  end

  def past24h_for_user(user, params) do
    from(notification in user_notifications(user),
      where: fragment("inserted_at::date >= (NOW() + INTERVAL '-1 day')"),
      order_by: [desc: :inserted_at]
    )
    |> Repo.paginate(params)
  end

  def delete_all_for_user(user) do
    user_notifications(user)
    |> Repo.delete_all
  end
end
