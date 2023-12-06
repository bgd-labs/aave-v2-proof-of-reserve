# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes
test   :; forge test -vvv

# Utilities
download :; cast etherscan-source --chain ${chain} -d src/etherscan/${chain}_${address} ${address}
git-diff :
	@mkdir -p diffs
	@npx prettier ${before} ${after} --write
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --diff-algorithm=patience --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md

storage-diff :;
	forge inspect etherscan/v2AmmEthPoolConfigurator/LendingPoolConfigurator/contracts/protocol/lendingpool/LendingPoolConfigurator.sol:LendingPoolConfigurator storage-layout --pretty > reports/v2AvaPoolConfigurator_layout.md
	npm run clean-storage-report v2AvaPoolConfigurator_layout
	forge inspect src/v2AvaEthPoolConfigurator/LendingPoolConfigurator/contracts/protocol/lendingpool/LendingPoolConfigurator.sol:LendingPoolConfigurator storage-layout --pretty > reports/updated_v2AvaPoolConfigurator_layout.md
	npm run clean-storage-report updated_v2AvaPoolConfigurator_layout
	make git-diff before=reports/v2AvaPoolConfigurator_layout.md after=reports/updated_v2AvaPoolConfigurator_layout.md out=v2AvaPoolConfigurator_layout_diff

# common
common-flags := --legacy --ledger --mnemonic-indexes $(MNEMONIC_INDEX) --sender $(LEDGER_SENDER) --verify -vvv --broadcast --slow

deploy-configurator-avalanche :; forge script ./scripts/DeployPoolConfigurator.s.sol:DeployAvalanche --rpc-url avalanche $(common-flags)