defmodule HackerSona.Content.Post.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    belongs_to :post, HackerSona.Content.Post
    belongs_to :user, HackerSona.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :post_id, :user_id])
    |> validate_required([:body, :post_id, :user_id])
    |> validate_length(:body, min: 5, max: 500)
  end
end
