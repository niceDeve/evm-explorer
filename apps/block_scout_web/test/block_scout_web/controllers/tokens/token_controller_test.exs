defmodule BlockScoutWeb.Tokens.TokenControllerTest do
  use BlockScoutWeb.ConnCase, async: true

  describe "GET show/2" do
    test "redirects to transfers page", %{conn: conn} do
      contract_address = insert(:address)

      conn = get(conn, token_path(conn, :show, contract_address.hash))

      assert conn.status == 302
    end
  end

  describe "GET token_counters/2" do
    test "returns token counters", %{conn: conn} do
      contract_address = insert(:address)

      insert(:token, contract_address: contract_address)

      token_id = 10

      insert(:token_transfer,
        from_address: contract_address,
        token_contract_address: contract_address,
        token_id: token_id
      )

      conn = get(conn, "/token_counters", %{"id" => to_string(contract_address.hash)})

      assert conn.status == 200
      {:ok, response} = Jason.decode(conn.resp_body)

      assert %{"token_holder_counter" => 0, "transfer_count" => 1} == response
    end
  end
end
