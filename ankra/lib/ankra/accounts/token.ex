defmodule Ankra.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    domain: Ankra.Accounts

  postgres do
    table "tokens"
    repo Ankra.Repo
  end
end
