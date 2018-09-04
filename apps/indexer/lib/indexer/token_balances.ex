defmodule Indexer.TokenBalances do
  @moduledoc """
  Reads Token's balances using Smart Contract functions from the blockchain.
  """

  alias Explorer.Token.BalanceReader

  @doc """
  Fetches TokenBalances from specific Addresses and Blocks in the Blockchain

  Every `TokenBalance` is fetched asynchronously, but in case an exception is raised (such as a
  timeout) during the RPC call the particular TokenBalance request is ignored.

  ## token_balances

  It is a list of a Map so that each map must have:

  * `token_contract_address_hash` - The contract address that represents the Token in the blockchain.
  * `address_hash` - The address_hash that we want to know the balance.
  * `block_number` - The block number that the address_hash has the balance.
  """
  def fetch_token_balances_from_blockchain(token_balances) do
    result =
      token_balances
      |> Task.async_stream(&fetch_token_balance/1, on_timeout: :kill_task)
      |> Stream.map(&format_task_results/1)
      |> Enum.filter(&ignore_request_with_timeouts/1)

    {:ok, result}
  end

  defp fetch_token_balance(
         %{
           token_contract_address_hash: token_contract_address_hash,
           address_hash: address_hash,
           block_number: block_number
         } = token_balance
       ) do
    token_contract_address_hash
    |> BalanceReader.get_balance_of(address_hash, block_number)
    |> set_token_balance_value(token_balance)
  end

  defp set_token_balance_value({:ok, balance}, token_balance) do
    Map.merge(token_balance, %{value: balance, value_fetched_at: DateTime.utc_now()})
  end

  defp set_token_balance_value({:error, _}, token_balance) do
    Map.merge(token_balance, %{value: nil, value_fetched_at: nil})
  end

  def format_task_results({:exit, :timeout}), do: {:error, :timeout}
  def format_task_results({:ok, token_balance}), do: token_balance

  def ignore_request_with_timeouts({:error, :timeout}), do: false
  def ignore_request_with_timeouts(_token_balance), do: true
end
