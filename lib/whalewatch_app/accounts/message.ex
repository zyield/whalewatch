defmodule WhalewatchApp.Accounts.Message do
  @moduledoc """
  A module for sending messages, by email or phone, to the user.

  This module provides functions to be used with the Phauxth authentication
  library when confirming users or handling password resets. It uses
  Bamboo, with the LocalAdapter, which is a good development tool.
  For tests, it uses a test adapter, which is configured in the
  config/test.exs file.

  For production, you will need to setup a different email adapter.

  ## Bamboo with a different adapter

  Bamboo has adapters for Mailgun, Mailjet, Mandrill, Sendgrid, SMTP,
  SparkPost, PostageApp, Postmark and Sendcloud.

  There is also a LocalAdapter, which is great for local development.

  See [Bamboo](https://github.com/thoughtbot/bamboo) for more information.

  ## Other email / phone library

  If you do not want to use Bamboo, follow the instructions below:

  1. Edit this file, using the email / phone library of your choice
  2. Remove the lib/whalewatch_app/mailer.ex file
  3. Remove the Bamboo entries in the config/config.exs and config/test.exs files
  4. Remove bamboo from the deps section in the mix.exs file

  """

  import Bamboo.Email
  alias WhalewatchApp.Mailer

  @base_url Application.get_env(:whalewatch_app, :base_url)

  @doc """
  An email with a confirmation link in it.
  """
  def confirm_request(address, key, onboarding \\ false) do
    confirm_url = case onboarding do
      false ->
        "#{@base_url}/confirm?key=#{key}"
      true ->
        "#{@base_url}/confirm?key=#{key}&onboarding=true"
    end

    body =
         "<html><body><p>Confirm your email address to complete your WhaleWatch.io account registration. It's easy - just click the button below.</p>"
      <> "<br>"
      <> "<a href=\"#{confirm_url}\">Confirm now</a>"
      <> "<br>"

    prep_mail(address)
    |> subject("Confirm your account")
    |> html_body(body)
    |> Mailer.deliver_now()
  end

  @doc """
  An email with a link to reset the password.
  """
  def reset_request(address, nil) do
    prep_mail(address)
    |> subject("Reset your password")
    |> text_body(
        "You requested a password reset, but no user is associated with the email you provided."
      )
    |> Mailer.deliver_now()
  end


  def reset_request(address, key) do
    body =
         "<p>We have received a request to reset your password on this WhaleWatch.io account.</p>"
      <> "<br>"
      <> "<p>Please click on this <a href=\"#{@base_url}/password_resets/edit?key=#{key}\">link to reset your password</a>"
      <> "or copy and paste this URL into your web browser's address bar:</p>"
      <> "<p>#{@base_url}/password_resets/edit?key=#{key}</p>"
      <> "<br>"

    prep_mail(address)
    |> subject("WhaleWatch.io - password reset request")
    |> html_body(body)
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def confirm_success(address) do
    body =
         "<p>Your email address and account have been confirmed. Thank you.</p>"
      <> "<p>You can now <a href=\"#{@base_url}/login\">login</a> to WhaleWatch.io and set up your alerts.</p>"

    prep_mail(address)
    |> subject("WhaleWatch.io account confirmed")
    |> html_body(body)
    |> Mailer.deliver_now()
  end

  @doc """
  An email acknowledging that the password has been successfully reset.
  """
  def reset_success(address) do
    prep_mail(address)
    |> subject("Password reset")
    |> text_body("Your password has been reset.")
    |> Mailer.deliver_now()
  end

  defp prep_mail(address) do
    new_email()
    |> to(address)
    |> from("no-reply@whalewatch.io")
  end
end
