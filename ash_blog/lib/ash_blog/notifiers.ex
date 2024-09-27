defmodule AshBlog.Notifiers do
  use Ash.Notifier

  def notify(%{action: %{type: :create}, data: post}) do
    Phoenix.PubSub.broadcast(AshBlog.PubSub, "post_creation", {:post_created, post})
  end
end
