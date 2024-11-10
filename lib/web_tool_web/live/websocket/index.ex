defmodule WebToolWeb.WebsocketLive.Index do
  use WebToolWeb, :live_view

  alias WebTool.WebsocketGenserver

  alias Phoenix.PubSub

  @channel "socket_tools"

  def mount(_params, _session, socket) do
    # Start the WebsocketGenserver (if not started by your supervisor)

    {:ok,
     assign(socket,
       form: %{
         "url" => "",
         "token" => "",
         "channel" => ""
       },
       channel: nil,
       token: nil,
       messages: [],
       connected?: false,
       joined?: false,
       topic: nil,
       pid: nil
     )}
  end

  def handle_event("connect_socket_submit", params, socket) do
    form = Map.merge(socket.assigns.form, params)

    with {:ok, pid} <-
           WebsocketGenserver.start_link(%{
             url: "#{params["url"]}?token=#{params["token"]}"
           }) do
      # WebsocketGenserver.send_message(message)
      PubSub.subscribe(WebTool.PubSub, @channel)
      {:noreply, assign(socket, connected?: true, pid: pid, form: form)}
    else
      _error -> {:noreply, assign(socket, connected?: false, form: form)}
    end
  end

  def handle_event("join_submit", params, socket) do
    form = Map.merge(socket.assigns.form, params)

    WebsocketGenserver.join_channel(params["channel"])
    {:noreply, assign(socket, joined?: true, topic: params["channel"], form: form)}
  end

  def handle_event("update_form", params, socket) do
    form = Map.merge(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("send_custom_message", %{"message" => msg}, socket) do
    message = %{
      topic: socket.assigns.topic,
      event: "start_merge",
      payload: %{message: msg},
      ref: 2
    }

    WebsocketGenserver.send_message(message)

    {:noreply, socket}
  end

  def handle_info({:message, msg}, socket) do
    message = Jason.decode!(msg)

    socket =
      if message["topic"] == socket.assigns.topic do
        if message["payload"]["status"] == "error" do
          assign(socket, topic: nil, joined?: false)
        else
          PubSub.subscribe(WebTool.PubSub, socket.assigns.topic)
          socket
        end
      else
        socket
      end

    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end
end
