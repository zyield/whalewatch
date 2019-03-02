defmodule WhalewatchApp.Accounts.MessageTest do
  use ExUnit.Case
  use Bamboo.Test

  import WhalewatchAppWeb.AuthCase
  alias WhalewatchApp.Accounts.Message

  setup do
    email = "deirdre@example.com"
    {:ok, %{email: email, key: gen_key(email)}}
  end

  test "sends confirmation request email", %{email: email, key: key} do
    body =
         "<p>Confirm your email address to complete your WhaleWatch.io account registration. It's easy - just click the button below.</p>"
      <> "<br>"
      <> "<a href=\"http://www.example.com/confirm?key=#{key}\">Confirm now</a>"
      <> "<br>"
      <> "<br>"
      <> "<br>"
      <> "Agile Alpha Inc."
      <> "<br>"
      <> "229 Niagara Street"
      <> "<br>"
      <> "Toronto, Ontario, Canada"

    sent_email = Message.confirm_request(email, key)
    assert sent_email.subject =~ "Confirm your account"
    assert sent_email.html_body =~ body
    assert_delivered_email(Message.confirm_request(email, key))
  end

  test "sends no user found message for password reset attempt" do
    sent_email = Message.reset_request("gladys@example.com", nil)
    assert sent_email.text_body =~ "but no user is associated with the email you provided"
  end

  test "sends reset password request email", %{email: email, key: key} do
    sent_email = Message.reset_request(email, key)
    assert sent_email.subject =~ "WhaleWatch.io - password reset request"
    assert_delivered_email(Message.reset_request(email, key))
  end

  test "sends receipt confirmation email", %{email: email} do
    sent_email = Message.confirm_success(email)
    assert sent_email.subject =~ "WhaleWatch.io account confirmed"
    assert_delivered_email(Message.confirm_success(email))
  end

  test "sends password reset email", %{email: email} do
    sent_email = Message.reset_success(email)
    assert sent_email.text_body =~ "Your password has been reset."
    assert_delivered_email(Message.reset_success(email))
  end
end
