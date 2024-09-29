defmodule Ankra.Customers do
  use Ash.Domain

  resources do
    resource Ankra.Customers.Customer do
      define :list_customers, action: :read
      define :filter_by_status, action: :filter_by_status, args: [:status]
      define :filter_by_role, action: :filter_by_status, args: [:role]
      define :new_customer, action: :create
      define :delete_customer_record, action: :destroy
      define :update_customer_record, action: :update
    end
  end

end
