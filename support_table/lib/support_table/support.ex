defmodule SupportTable.Support do
  use Ash.Domain

  resources do
    resource SupportTable.Support.Ticket
    resource SupportTable.Support.Representative
  end
end
