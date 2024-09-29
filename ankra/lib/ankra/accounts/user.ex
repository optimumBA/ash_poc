defmodule Ankra.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    domain: Ankra.Accounts

  postgres do
    table "users"
    repo Ankra.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :viewer]
      default :viewer
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_email, [:email]
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
        sign_in_tokens_enabled? true
        confirmation_required? false
        register_action_accept [:role]
      end
    end

    tokens do
      enabled? true
      token_resource Ankra.Accounts.Token
      signing_secret Ankra.Accounts.Secrets
    end
  end

  actions do
    defaults [:read]
  end

  actions do
    defaults [:read, :destroy]

    read :get_by_id do
      get? true

      argument :user_id, :uuid, allow_nil?: false

      filter expr(id == ^arg(:user_id))
    end

    update :make_admin do
      accept []
      change set_attribute(:role, :admin)
    end
  end
end

# TODO: Update policy such that only an admin can CRUD
