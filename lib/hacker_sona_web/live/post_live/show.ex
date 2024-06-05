defmodule HackerSonaWeb.PostLive.Show do
  use HackerSonaWeb, :live_view

  alias HackerSona.Content
  alias HackerSonaWeb.Presence
  alias HackerSonaWeb.CommentFormComponent

  @topic "post"
  @impl true
  def mount(%{"id" => post_id} = _params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Phoenix.PubSub.subscribe(HackerSona.PubSub, "#{@topic}:#{post_id}")
      Content.subscribe(post_id)

      {:ok, _} =
        Presence.track(self(), "#{@topic}:#{post_id}", current_user.id, %{
          username: current_user.email |> String.split("@") |> hd()
        })
    end

    presences = Presence.list("#{@topic}:#{post_id}")
    socket = socket |> assign(:presences, simple_presence_map(presences))

    {:ok,
     assign(socket,
       post_id: post_id
     ), temporary_assigns: [post: %Content.Post{}]}
  end


  def simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: metas}} ->
      {user_id, hd(metas)}
    end)
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Content.get_post_with_comments!(id)
    comments = post.comments

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> stream(:comments, comments)
     |> assign(:post, post)}
  end

  def comments(assigns) do
    ~H"""
    <div :if={@post.comments}>
      <h2>Comments</h2>
      <div id="comments" phx-update="stream">
        <div :for={{comment_id, comment} <- @comments} id={comment_id}>
          <p><%= comment.body %></p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:comment_created, comment}, socket) do
    {:noreply, stream_insert(socket, :comments, comment, at: 0)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket = socket |> remove_presences(diff.leaves) |> add_presences(diff.joins)
    {:noreply, socket}
  end

  def remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, &elem(&1, 0))
    presences = Map.drop(socket.assigns.presences, user_ids)
    assign(socket, presences: presences)
  end

  def add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))
    assign(socket, presences: presences)
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
