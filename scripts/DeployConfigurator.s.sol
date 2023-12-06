// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import {Script} from 'forge-std/Script.sol';
import {console} from 'forge-std/console.sol';
import {AaveV2Avalanche} from 'aave-address-book/AaveV2Avalanche.sol';
import {LendingPoolConfigurator, ILendingPoolAddressesProvider} from 'src/v2AvaEthPoolConfigurator/LendingPoolConfigurator/contracts/protocol/lendingpool/LendingPoolConfigurator.sol';

import {ConfiguratorUpdatePayload} from 'src/payloads/ConfiguratorUpdatePayload.sol';

library DeployConfiguratorLib {
  function deploy() internal returns (address) {
    address poolConfigurator = address(new LendingPoolConfigurator());
    LendingPoolConfigurator(poolConfigurator).initialize(
      ILendingPoolAddressesProvider(address(AaveV2Avalanche.POOL_ADDRESSES_PROVIDER))
    );

    ConfiguratorUpdatePayload payload = new ConfiguratorUpdatePayload(address(poolConfigurator));

    console.log('Pool Configurator Impl address', address(poolConfigurator));
    console.log('Payload address', address(payload));

    return address(payload);
  }
}

contract DeployAvalanche is Script {
  function run() external {
    vm.startBroadcast();

    DeployConfiguratorLib.deploy();

    vm.stopBroadcast();
  }
}
