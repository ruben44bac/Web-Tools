defmodule WebTool.CacheDets do
  @table_name :local_sessions

  def init(opts, table_name \\ @table_name) do
    :dets.open_file(table_name, opts)
  end

  def get(key, table_name \\ @table_name) do
    case :dets.lookup(table_name, key) do
      [{^key, value}] -> {:ok, value}
      [] -> {:ok, nil}
    end
  end

  def put(key, value, table_name \\ @table_name) do
    :dets.insert(table_name, {key, value})
  end
end
