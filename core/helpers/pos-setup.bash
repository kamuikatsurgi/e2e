# This function sets up environment variables for `pos` tests using a Kurtosis Polygon PoS
# environment if they are not already provided.
pos_setup() {
  # Private key used to send transactions.
  export PRIVATE_KEY=${PRIVATE_KEY:-"0xd40311b5a5ca5eaeb48dfba5403bde4993ece8eccf4190e98e19fcd4754260ea"}
  echo "PRIVATE_KEY=${PRIVATE_KEY}"

  # The type of the L2 CL node is used to determine how to fetch the different RPC and API URLs.
  export L2_CL_NODE_TYPE=${L2_CL_NODE_TYPE:-"heimdall"}
  if [[ "${L2_CL_NODE_TYPE}" != "heimdall" && "${L2_CL_NODE_TYPE}" != "heimdall-v2" ]]; then
    echo "❌ Wrong L2 CL node type given: '${L2_CL_NODE_TYPE}'. Expected 'heimdall' or 'heimdall-v2'."
    exit 1
  fi
  echo "L2_CL_NODE_TYPE=${L2_CL_NODE_TYPE}"

  # The name of the Kurtosis enclave (used for default values).
  export ENCLAVE_NAME=${ENCLAVE_NAME:-"pos"}
  echo "ENCLAVE_NAME=${ENCLAVE_NAME}"

  # L1 and L2 RPC and API URLs.
  export L1_RPC_URL=${L1_RPC_URL:-"http://$(kurtosis port print "${ENCLAVE_NAME}" el-1-geth-lighthouse rpc)"}
  echo "L1_RPC_URL=${L1_RPC_URL}"
  if [[ "${L2_CL_NODE_TYPE}" == "heimdall" ]]; then
    export L2_RPC_URL=${L2_RPC_URL:-$(kurtosis port print "${ENCLAVE_NAME}" "l2-el-1-bor-heimdall-validator" rpc)}
    export L2_CL_API_URL=${L2_CL_API_URL:-$(kurtosis port print "${ENCLAVE_NAME}" "l2-cl-1-heimdall-bor-validator" http)}
  elif [[ "${L2_CL_NODE_TYPE}" == "heimdall-v2" ]]; then
    export L2_RPC_URL=${L2_RPC_URL:-$(kurtosis port print "${ENCLAVE_NAME}" "l2-el-1-bor-heimdall-v2-validator" rpc)}
    export L2_CL_API_URL=${L2_CL_API_URL:-$(kurtosis port print "${ENCLAVE_NAME}" "l2-cl-1-heimdall-v2-bor-validator" http)}
  fi
  echo "L2_RPC_URL=${L2_RPC_URL}"
  echo "L2_CL_API_URL=${L2_CL_API_URL}"

  if [[ -z "${L1_DEPOSIT_MANAGER_PROXY_ADDRESS:-}" ]] ||
   [[ -z "${L1_STAKE_MANAGER_PROXY_ADDRESS:-}" ]] ||
   [[ -z "${L1_MATIC_TOKEN_ADDRESS:-}" ]] ||
   [[ -z "${L1_ERC20_TOKEN_ADDRESS:-}" ]] ||
   [[ -z "${L1_ERC721_TOKEN_ADDRESS:-}" ]] ||
   [[ -z "${L2_STATE_RECEIVER_ADDRESS:-}" ]] ||
   [[ -z "${L2_ERC20_TOKEN_ADDRESS:-}" ]] ||
   [[ -z "${L2_ERC721_TOKEN_ADDRESS:-}" ]]; then
    matic_contract_addresses=$(kurtosis files inspect "${ENCLAVE_NAME}" matic-contract-addresses contractAddresses.json | tail -n +2 | jq)

    # L1 contract addresses.
    export L1_DEPOSIT_MANAGER_PROXY_ADDRESS=${L1_DEPOSIT_MANAGER_PROXY_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.root.DepositManagerProxy')}
    echo "L1_DEPOSIT_MANAGER_PROXY_ADDRESS=${L1_DEPOSIT_MANAGER_PROXY_ADDRESS}"

    export L1_STAKE_MANAGER_PROXY_ADDRESS=${L1_STAKE_MANAGER_PROXY_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.root.StakeManagerProxy')}
    echo "L1_STAKE_MANAGER_PROXY_ADDRESS=${L1_STAKE_MANAGER_PROXY_ADDRESS}"

    export L1_MATIC_TOKEN_ADDRESS=${L1_MATIC_TOKEN_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.root.tokens.MaticToken')}
    echo "L1_MATIC_TOKEN_ADDRESS=${L1_MATIC_TOKEN_ADDRESS}"

    export L1_ERC20_TOKEN_ADDRESS=${L1_ERC20_TOKEN_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.root.tokens.TestToken')}
    echo "L1_ERC20_TOKEN_ADDRESS=${L1_ERC20_TOKEN_ADDRESS}"

    export L1_ERC721_TOKEN_ADDRESS=${L1_ERC721_TOKEN_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.root.tokens.RootERC721')}
    echo "L1_ERC721_TOKEN_ADDRESS=${L1_ERC721_TOKEN_ADDRESS}"

    # L2 contract addresses.
    export L2_STATE_RECEIVER_ADDRESS=${L2_STATE_RECEIVER_ADDRESS:-$(kurtosis files inspect "${ENCLAVE_NAME}" l2-el-genesis genesis.json | tail -n +2 | jq --raw-output '.config.bor.stateReceiverContract')}
    echo "L2_STATE_RECEIVER_ADDRESS=${L2_STATE_RECEIVER_ADDRESS}"

    export L2_ERC20_TOKEN_ADDRESS=${L2_ERC20_TOKEN_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.child.tokens.TestToken')}
    echo "L2_ERC20_TOKEN_ADDRESS=${L2_ERC20_TOKEN_ADDRESS}"

    export L2_ERC721_TOKEN_ADDRESS=${L2_ERC721_TOKEN_ADDRESS:-$(echo "${matic_contract_addresses}" | jq --raw-output '.child.tokens.RootERC721')}
    echo "L2_ERC721_TOKEN_ADDRESS=${L2_ERC721_TOKEN_ADDRESS}"
  fi
}
