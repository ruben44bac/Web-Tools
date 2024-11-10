defmodule WebToolWeb.HomeLive.Index do
  use WebToolWeb, :live_view

  import WebToolWeb.CoreComponents

  alias WebTool.CacheDets

  def mount(_params, _session, socket) do
    CacheDets.init(type: :set)

    {:ok, user_name} =
      CacheDets.get("username")

    {:ok, assign(socket, user_name: user_name, form: %{})}
  end

  def handle_event("change_form", params, socket) do
    {:noreply, assign(socket, form: params)}
  end

  def handle_event("submit_form", params, socket) do
    CacheDets.put("username", params["user_name"])

    {:noreply, assign(socket, form: params, user_name: params["user_name"])}
  end

  def handle_event("open_tool", %{"type" => type}, socket) do
    {:noreply, redirect(socket, to: "/#{type}")}
  end
end
