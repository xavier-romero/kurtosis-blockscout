# Polygon CDK Blockscout Stack
This is a Kurtosis based stack to deploy Blockscout on arbitrary CDK/zkEVM based chain.

## Configuration
Be sure to have Kurtosis installed on you computer: https://docs.kurtosis.com/install/

Create a params.yaml file with these 5 parameters (only 3 required)
- blockscout_public_port: OPTIONAL, set the port on which you'll have Blockscout available, 8000 by default
- rpc_url: REQUIRED, set a RPC URL
- trace_url: OPTIONAL, set a RPC URL with debug endpoints enabled
- ws_url: REQUIRED, set WS URL
- chain_id_ REQUIRED, set the chain id for the network to monitor

### Example:
File params.yaml
```
rpc_url: https://rpc.cardona.zkevm-rpc.com
ws_url: wss://ws.cardona.zkevm-rpc.com
chain_id: 2442
```
This will bring a Cardona Blockscout on http://127.0.0.1:8000

## Execution
```
kurtosis run github.com/xavier-romero/kurtosis-blockscout --args-file params.yaml --enclave blockscout
```