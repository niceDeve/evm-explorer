defmodule ExplorerWeb.TransactionController do
  use ExplorerWeb, :controller

  import ExplorerWeb.Chain, only: [paging_options: 1]

  alias Explorer.Chain

  @page_size 50

  def index(conn, params) do
    full_options =
      Keyword.merge(
        [
          necessity_by_association: %{
            block: :required,
            from_address: :optional,
            to_address: :optional
          }
        ],
        paging_options(params)
      )

    transactions_plus_one = Chain.recent_collated_transactions(full_options)

    {transactions, next_page} = Enum.split(transactions_plus_one, @page_size)

    transaction_estimated_count = Chain.transaction_estimated_count()

    render(
      conn,
      "index.html",
      next_page_params: next_page_params(next_page, transactions),
      transaction_estimated_count: transaction_estimated_count,
      transactions: transactions
    )
  end

  def show(conn, %{"id" => id, "locale" => locale}) do
    redirect(conn, to: transaction_internal_transaction_path(conn, :index, locale, id))
  end

  defp next_page_params([], _transactions), do: nil

  defp next_page_params(_, transactions) do
    last = List.last(transactions)
    %{block_number: last.block_number, index: last.index}
  end
end
