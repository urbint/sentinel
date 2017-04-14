defmodule Sentinel.Reloader do
  use GenServer

  @behaviour Sentinel.Controller.Stage

  ##########################################
  # Public API
  ##########################################

  @spec start_link :: GenServer.on_start
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  @spec reload_file(Path.t) :: :ok | {:error, String.t}
  def reload_file(path) do
    GenServer.call(__MODULE__, {:reload_file, path})
  end

  @spec recompile() :: :ok
  def recompile() do
    GenServer.call(__MODULE__, {:recompile})
  end

  ##########################################
  # Controller Stage Callbacks
  ##########################################
  
  def file_changed(:lib, path) do
    if File.exists?(path) do
      reload_file(path)
    else
      recompile()
    end
  end
  def file_changed(_, _), do: :ok



  ##########################################
  # GenServer Callbacks
  ##########################################
  
  def init(_) do
    {:ok, %{}}
  end


  def handle_call({:reload_file, path}, _from, state) do
    restore_opts =
      Code.compiler_options()

    Code.compiler_options(ignore_module_conflict: true)

    Code.load_file(path)

    Code.compiler_options(restore_opts)
    
    {:reply, :ok, state}
  end

  def handle_call({:recompile}, _from, state) do
    IEx.Helpers.recompile()
    {:reply, :ok, state}
  end
end