use Mix.Config

config :indexer,
  block_interval: :timer.seconds(5),
  json_rpc_named_arguments: [
    transport: EthereumJSONRPC.HTTP,
    transport_options: [
      http: EthereumJSONRPC.HTTP.HTTPoison,
      url: System.get_env("ETHEREUM_JSONRPC_HTTP_URL"),
      http_options: [recv_timeout: :timer.minutes(10), timeout: :timer.minutes(10), hackney: [pool: :ethereum_jsonrpc]]
    ],
    variant: EthereumJSONRPC.Geth
  ],
  subscribe_named_arguments: [
    transport: EthereumJSONRPC.WebSocket,
    transport_options: [
      web_socket: System.get_env("ETHEREUM_JSONRPC_TRACE_URL") || EthereumJSONRPC.WebSocket.WebSocketClient,
      url: System.get_env("ETHEREUM_JSONRPC_WS_URL")
    ]
  ]
