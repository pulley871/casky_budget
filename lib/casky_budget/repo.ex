defmodule CaskyBudget.Repo do
  use Ecto.Repo,
    otp_app: :casky_budget,
    adapter: Ecto.Adapters.Postgres
end
