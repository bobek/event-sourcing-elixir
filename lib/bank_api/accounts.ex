defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias BankAPI.Repo
  alias BankAPI.Router
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Projections.Account

  def get_account(uuid), do: Repo.get!(Account, uuid)

  def open_account(account_params) do
    changeset = account_opening_changeset(account_params)

    if changeset.valid? do
      account_uuid = UUID.uuid4()

      dispatch_result =
        %OpenAccount{
          initial_balance: changeset.changes.initial_balance,
          account_uuid: account_uuid
        }
        |> Router.dispatch(consistency: :strong)

      case dispatch_result do
        :ok ->
          {
            :ok,
            # Following is for optimistic consistency:
            # %Account{
            #   uuid: account_uuid,
            #   current_balance: changeset.changes.initial_balance
            # }
            # but as we have switched to consistency `:strong` we can fetch from the DB
            get_account(account_uuid)
          }

        reply ->
          reply
      end
    else
      {:validation_error, changeset}
    end
  end

  defp account_opening_changeset(params) do
    {
      params,
      %{initial_balance: :integer}
    }
    |> Changeset.cast(params, [:initial_balance])
    |> Changeset.validate_required([:initial_balance])
    |> Changeset.validate_number(:initial_balance, greater_than: 0)
  end
end
