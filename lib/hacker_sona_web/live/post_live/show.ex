defmodule HackerSonaWeb.PostLive.Show do
  use HackerSonaWeb, :live_view

  alias HackerSona.Content
  alias HackerSonaWeb.CommentFormComponent

  @impl true
  def mount(%{"id" => post_id} = _params, _session, socket) do
    {:ok,
     assign(socket,
       post_id: post_id
     ), temporary_assigns: [post: %Content.Post{}]}
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

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
