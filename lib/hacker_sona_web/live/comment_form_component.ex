defmodule HackerSonaWeb.CommentFormComponent do
  use HackerSonaWeb, :live_component
  alias HackerSona.Content
  alias HackerSona.Content.Post.Comment

  @impl true
  def update(%{post_id: post_id} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_post_and_user()

    comment_changeset = Content.change_comment(%Comment{post_id: post_id})
    {:ok, assign(socket, form: to_form(comment_changeset))}
  end

  defp assign_post_and_user(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, post_id: socket.assigns.post_id, current_user: current_user)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-4">
      <.form
        for={@form}
        phx-change="validate"
        id="comment-form"
        phx-submit="save_comment"
        phx-target={@myself}
        class="flex flex-col space-y-4"
      >
        <.input
          field={@form[:body]}
          placeholder="Write your Comment Here"
          phx-debounce="2000"
          class="px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
        />
        <.button
          phx-disable-with="Saving..."
          class="px-4 py-2 bg-orange-500 text-white rounded hover:bg-orange-600"
        >
          Submit Comment
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("save_comment", %{"comment" => comment_params} = _params, socket) do
    comment_params = merge_comment_params(comment_params, socket)

    case Content.create_comment(comment_params) do
      {:ok, comment} ->
        send(self(), {:comment_created, comment})

        {:noreply, assign(socket, form: to_form(Content.change_comment(%Comment{})))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate", %{"comment" => comment_params} = _params, socket) do
    comment_params = merge_comment_params(comment_params, socket)
    changeset = Content.change_comment(%Comment{}, comment_params) |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  defp merge_comment_params(comment_params, socket) do
    Map.merge(comment_params, %{
      "user_id" => socket.assigns.current_user.id,
      "post_id" => socket.assigns.post_id
    })
  end
end
