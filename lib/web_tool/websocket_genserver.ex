defmodule WebTool.WebsocketGenserver do
  use GenServer

  alias WebTool.WebsocketTest

  # Starts the GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    {:ok, pid} = WebsocketTest.start_link(state.url)

    {:ok, Map.put(state, :ws_client, pid)}
  end

  def send_message(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  def handle_call({:send_message, message}, _from, state) do
    WebsocketTest.send_message(state[:ws_client], message)
    {:reply, :ok, state}
  end

  def handle_call({:join_channel, channel}, _from, state) do
    WebsocketTest.join_channel(state[:ws_client], channel)
    {:reply, :ok, state}
  end

  def join_channel(channel) do
    GenServer.call(__MODULE__, {:join_channel, channel})
  end
end
