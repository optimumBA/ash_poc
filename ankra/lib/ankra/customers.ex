defmodule Ankra.Customers do
  use Ash.Domain

  resources do
    resource Ankra.Customers.Customer do
      define :list_customers, action: :read, args: [:filter]
      define :new_customer, action: :create
      define :delete_customer_record, action: :destroy
      define :update_customer_record, action: :update
    end
  end
end
