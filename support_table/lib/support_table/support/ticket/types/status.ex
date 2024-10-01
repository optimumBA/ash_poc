defmodule SupportTable.Support.Ticket.Types.Status do
  use Ash.Type.Enum, values: [:open, :closed]
end
