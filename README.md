# Aave Proof of Reserve overview

Repository containing the update of the Pool Configurator and payload to activate Proof of Reserve mechanism for Aave Avalanche V2 pool.

Proof-of-Reserve is a system by Chainlink that allows for reliable monitoring of reserve assets, and usage of that data feed directly on-chain. If anomaly will be detected for a single asset, the system will try to apply the highest possible protections on the pool.

More detailed documentation on Proof of Reserve could be found [here](https://github.com/bgd-labs/aave-proof-of-reserve/blob/main/README.md)

## Technical details

The following modifiers are added to the PoolConfigurator:

- `onlyPoolOrEmergencyAdminOrProofOfReserve` is applied to the `freezeReserve()` method.
- `onlyPoolOrProofOfReserveAdmin` is applied to the `disableBorrowingOnReserve()` and `disableReserveStableRate()` methods.

[ConfiguratorUpdatePayload](./src/payloads/ConfiguratorUpdatePayload.sol) updates the implementation of the PoolConfigurator and sets [Proof of Reserve Executor v2](https://snowtrace.io/address/0x7fc3FCb14eF04A48Bb0c12f0c39CD74C249c37d8) as the `PROOF_OF_RESERVE_ADMIN`;

## Diffs

[PoolConfigurator](./diffs/v2AmmEthPoolConfigurator.md)
[PoolConfigurator storage layout](./diffs/v2AvaPoolConfigurator_layout_diff.md)

## SetUp

This repo has forge and npm dependencies, so you will need to install foundry then run:

```
forge install
```

and also run:

```
yarn
```

## Tests

To run the tests just run:

```
forge test
```

## Copyright

Copyright © 2023, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

[MIT license](./LICENSE)
