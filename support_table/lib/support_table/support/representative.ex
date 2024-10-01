defmodule SupportTable.Support.Representative do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: SupportTable.Support

  postgres do
    table "representatives"
    repo SupportTable.Repo
  end

  actions do
    defaults [:read, create: [:name]]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    has_many :tickets, SupportTable.Support.Ticket do
      public? true
    end
  end
end
