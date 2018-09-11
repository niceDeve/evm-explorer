defmodule Indexer.BlockFetcher.Catchup.Supervisor do
  @moduledoc """
  Supervises `Indexer.BlockFetcher.Catchup.TaskSupervisor` and `Indexer.BlockFetcher.Catchup.BoundIntervalSupervisor`
  """

  use Supervisor

  alias Indexer.BlockFetcher.Catchup.BoundIntervalSupervisor

  def child_spec([init_arguments]) do
    child_spec([init_arguments, []])
  end

  def child_spec([_init_arguments, _gen_server_options] = start_link_arguments) do
    default = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, start_link_arguments},
      type: :supervisor
    }

    Supervisor.child_spec(default, [])
  end

  def start_link(arguments, gen_server_options \\ []) do
    Supervisor.start_link(__MODULE__, arguments, gen_server_options)
  end

  @impl Supervisor
  def init(bound_interval_supervisor_arguments) do
    Supervisor.init(
      [
        {Task.Supervisor, name: Indexer.BlockFetcher.Catchup.TaskSupervisor},
        {BoundIntervalSupervisor, [bound_interval_supervisor_arguments, [name: BoundIntervalSupervisor]]}
      ],
      strategy: :one_for_one
    )
  end
end
