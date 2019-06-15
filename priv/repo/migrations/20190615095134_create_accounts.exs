# See lib/bank_api/accounts/projections/account.ex for projection

defmodule BankAPI.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :current_balance, :integer

      timestamps()
    end
  end
end
