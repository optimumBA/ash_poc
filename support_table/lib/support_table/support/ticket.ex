defmodule SupportTable.Support.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: SupportTable.Support

  postgres do
    table "tickets"
    repo SupportTable.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:subject, :status, :representative_id]
    end

    update :close do
      accept []

      validate attribute_does_not_equal(:status, :closed) do
        message "Ticket is already closed"
      end

      change set_attribute(:status, :closed)
    end

    update :assign do
      accept [:representative_id]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :subject, :string do
      allow_nil? false
      public? true
    end

    attribute :status, :ticket_status do
      default :open
      allow_nil? false
    end

    attribute :inserted_at, :utc_datetime_usec do
      default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :representative, SupportTable.Support.Representative do
      public? true
    end
  end
end
