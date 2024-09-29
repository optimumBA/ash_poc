defmodule Ankra.Customers.Customer do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Ankra.Customers,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "customers"
    repo Ankra.Repo
  end

  actions do
    defaults [:read, :destroy, :update]

    create :create do
      accept [:email, :first_name, :last_name, :phone_number, :role, :status, :avatar]

      change relate_actor(:user)
    end

    read :filter_by_status do
      argument :status, :atom, allow_nil?: false

      filter expr(status == ^arg(:status))
    end

    read :filter_by_role do
      argument :role, :atom, allow_nil?: false

      filter expr(role == ^arg(:role))
    end
  end

  policies do
    policy action_type([:create, :read]) do
      description "Anyone can add a customer"
      authorize_if always()
    end

    policy action_type(:update) do
      description "Only an admin or the user who created the customer record"
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:destroy) do
      description "Only an admin can delete a record"
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true
    attribute :phone_number, :string, allow_nil?: false, public?: true
    attribute :role, :string, allow_nil?: false, public?: true

    attribute :status, :atom do
      constraints one_of: [:active, :pending, :cancelled]
      default :active
      allow_nil? false
    end

    attribute :avatar, :string, allow_nil?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end


  identities do
    identity :unique_email, [:email]
  end

  relationships do
    belongs_to :user, Ankra.Accounts.User, allow_nil?: false
  end

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end
end
