defmodule AshBlog.Posts.Post do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: AshBlog.Posts,
    notifiers: [AshBlog.Notifiers]

  postgres do
    table "posts"
    repo AshBlog.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :list do
      pagination keyset?: true, default_limit: 10
      prepare build(sort: :inserted_at)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false, public?: true
    attribute :body, :string, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
