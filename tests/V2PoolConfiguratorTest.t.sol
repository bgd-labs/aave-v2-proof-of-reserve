// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import 'forge-std/Test.sol';
import {Errors} from 'src/v2AvaEthPoolConfigurator/LendingPoolConfigurator/contracts/protocol/libraries/helpers/Errors.sol';
import {ILendingPoolConfigurator, IAaveProtocolDataProvider} from 'aave-address-book/AaveV2.sol';
import {AaveV2Avalanche, AaveV2AvalancheAssets} from 'aave-address-book/AaveV2Avalanche.sol';
import {IExecutor} from './utils/IExecutor.sol';
import {DeployConfiguratorLib} from '../scripts/DeployConfigurator.s.sol';

contract V2EthPoolConfiguratorTest is Test {
  address public constant AVA_PAYLOADS_CONTROLLER = 0x1140CB7CAfAcC745771C2Ea31e7B5C653c5d0B80; // PAYLOADS_CONTROLLER
  address public constant AVA_EXECUTOR_LVL_1 = 0x3C06dce358add17aAf230f2234bCCC4afd50d090; // EXECUTOR_LVL_1

  address public constant PROOF_OF_RESERVE_ADMIN = 0x7fc3FCb14eF04A48Bb0c12f0c39CD74C249c37d8;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 38690405);
    _deployAndExecutePayload();
  }

  function _deployAndExecutePayload() internal {
    address payload = DeployConfiguratorLib.deploy();
    hoax(AVA_PAYLOADS_CONTROLLER);
    IExecutor(AVA_EXECUTOR_LVL_1).executeTransaction(
      address(payload),
      0,
      'execute()',
      bytes(''),
      true
    );
  }

  function test_reverts_freezeReserve() public {
    address caller = msg.sender;

    vm.assume(
      caller != AaveV2Avalanche.EMERGENCY_ADMIN &&
        caller != AaveV2Avalanche.POOL_ADMIN &&
        caller != PROOF_OF_RESERVE_ADMIN &&
        caller != address(AaveV2Avalanche.POOL_ADDRESSES_PROVIDER)
    );

    vm.expectRevert(bytes(Errors.LPC_CALLER_NOT_POOL_OR_EMERGENCY_OR_PROOF_OF_RESERVE_ADMIN));

    ILendingPoolConfigurator(AaveV2Avalanche.POOL_CONFIGURATOR).freezeReserve(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
  }

  function test_freezeReserve_emergencyAdmin() public {
    (, , , , , , , , , bool isFrozenBefore) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenBefore, false);

    vm.startPrank(AaveV2Avalanche.EMERGENCY_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.freezeReserve(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    vm.stopPrank();

    (, , , , , , , , , bool isFrozenAfter) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenAfter, true);
  }

  function test_freezeReserve_poolAdmin() public {
    (, , , , , , , , , bool isFrozenBefore) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenBefore, false);

    vm.startPrank(AaveV2Avalanche.POOL_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.freezeReserve(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    vm.stopPrank();

    (, , , , , , , , , bool isFrozenAfter) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenAfter, true);
  }

  function test_freezeReserve_proofOfReserveAdmin() public {
    (, , , , , , , , , bool isFrozenBefore) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenBefore, false);

    vm.startPrank(PROOF_OF_RESERVE_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.freezeReserve(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    vm.stopPrank();

    (, , , , , , , , , bool isFrozenAfter) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(isFrozenAfter, true);
  }

  function test_reverts_disableBorrowing() public {
    address caller = msg.sender;

    vm.assume(
      caller != AaveV2Avalanche.POOL_ADMIN &&
        caller != PROOF_OF_RESERVE_ADMIN &&
        caller != address(AaveV2Avalanche.POOL_ADDRESSES_PROVIDER)
    );

    vm.expectRevert(bytes(Errors.LPC_CALLER_NOT_POOL_OR_PROOF_OF_RESERVE_ADMIN));

    ILendingPoolConfigurator(AaveV2Avalanche.POOL_CONFIGURATOR).disableBorrowingOnReserve(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
  }

  function test_disableBorrowing_poolAdmin() public {
    (, , , , , , bool borrowingEnabledBefore, , , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(borrowingEnabledBefore, true);

    vm.startPrank(AaveV2Avalanche.POOL_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.disableBorrowingOnReserve(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
    vm.stopPrank();

    (, , , , , , bool borrowingEnabledAfter, , , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(borrowingEnabledAfter, false);
  }

  function test_disableBorrowing_proofOfReserveAdmin() public {
    (, , , , , , bool borrowingEnabledBefore, , , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(borrowingEnabledBefore, true);

    vm.startPrank(PROOF_OF_RESERVE_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.disableBorrowingOnReserve(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
    vm.stopPrank();

    (, , , , , , bool borrowingEnabledAfter, , , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(borrowingEnabledAfter, false);
  }

  function test_reverts_disableStableBorrowing() public {
    address caller = msg.sender;

    vm.assume(
      caller != AaveV2Avalanche.POOL_ADMIN &&
        caller != PROOF_OF_RESERVE_ADMIN &&
        caller != address(AaveV2Avalanche.POOL_ADDRESSES_PROVIDER)
    );

    vm.expectRevert(bytes(Errors.LPC_CALLER_NOT_POOL_OR_PROOF_OF_RESERVE_ADMIN));

    ILendingPoolConfigurator(AaveV2Avalanche.POOL_CONFIGURATOR).disableReserveStableRate(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
  }

  function test_disableStableBorrowing_poolAdmin() public {
    vm.startPrank(AaveV2Avalanche.POOL_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.disableReserveStableRate(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
    vm.stopPrank();

    (, , , , , , , bool stableBorrowingEnabled, , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(stableBorrowingEnabled, false);
  }

  function test_disableStableBorrowing_proofOfReserveAdmin() public {
    vm.startPrank(PROOF_OF_RESERVE_ADMIN);
    AaveV2Avalanche.POOL_CONFIGURATOR.disableReserveStableRate(
      AaveV2AvalancheAssets.DAIe_UNDERLYING
    );
    vm.stopPrank();

    (, , , , , , , bool stableBorrowingEnabled, , ) = IAaveProtocolDataProvider(
      AaveV2Avalanche.AAVE_PROTOCOL_DATA_PROVIDER
    ).getReserveConfigurationData(AaveV2AvalancheAssets.DAIe_UNDERLYING);
    assertEq(stableBorrowingEnabled, false);
  }
}
