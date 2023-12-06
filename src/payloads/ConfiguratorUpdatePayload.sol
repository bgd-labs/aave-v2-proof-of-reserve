// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import {ILendingPoolAddressesProvider} from 'aave-address-book/AaveV2.sol';
import {AaveV2Avalanche} from 'aave-address-book/AaveV2Avalanche.sol';

contract ConfiguratorUpdatePayload {
  address public immutable NEW_POOL_CONFIGURATOR_IMPL;
  address public constant PROOF_OF_RESERVE_EXECUTOR_V2 = 0x7fc3FCb14eF04A48Bb0c12f0c39CD74C249c37d8;
  bytes32 public constant PROOF_OF_RESERVE_ADMIN = 'PROOF_OF_RESERVE_ADMIN';

  constructor(address poolConfiguratorImpl) public {
    NEW_POOL_CONFIGURATOR_IMPL = poolConfiguratorImpl;
  }

  function execute() public {
    ILendingPoolAddressesProvider(AaveV2Avalanche.POOL_ADDRESSES_PROVIDER)
      .setLendingPoolConfiguratorImpl(NEW_POOL_CONFIGURATOR_IMPL);

    // set ProofOfReserveExecutorV2 as PROOF_OF_RESERVE_ADMIN
    AaveV2Avalanche.POOL_ADDRESSES_PROVIDER.setAddress(
      PROOF_OF_RESERVE_ADMIN,
      address(PROOF_OF_RESERVE_EXECUTOR_V2)
    );
  }
}
