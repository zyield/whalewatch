defmodule WhalewatchAppWeb.SharedView do
  use WhalewatchAppWeb, :view

  def gravatar(email, opts \\ []) do
    hash = email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)

    img = "https://www.gravatar.com/avatar/#{hash}?s=150&d=identicon"
    img_tag(img, opts)
  end
end
