```diff
diff --git a/etherscan/flattened/v2AvaEthPoolConfigurator/LendingPoolConfigurator.sol b/src/v2AvaEthPoolConfigurator/LendingPoolConfigurator/flattened/LendingPoolConfigurator.sol
index 4229340..a21f88d 100644
--- a/etherscan/flattened/v2AvaEthPoolConfigurator/LendingPoolConfigurator.sol
+++ b/src/v2AvaEthPoolConfigurator/LendingPoolConfigurator/flattened/LendingPoolConfigurator.sol
@@ -637,6 +637,8 @@ library Errors {
   string public constant SDT_STABLE_DEBT_OVERFLOW = '79';
   string public constant SDT_BURN_EXCEEDS_BALANCE = '80';
   string public constant LPC_CALLER_NOT_POOL_OR_EMERGENCY_ADMIN = '83'; // 'The caller must be the emergency or pool admin'
+  string public constant LPC_CALLER_NOT_POOL_OR_EMERGENCY_OR_PROOF_OF_RESERVE_ADMIN = '84'; // 'The caller must be the emergency or pool or proof of reserve admin'
+  string public constant LPC_CALLER_NOT_POOL_OR_PROOF_OF_RESERVE_ADMIN = '85'; // 'The caller must be the pool or proof of reserve admin'
 
   enum CollateralManagerErrors {
     NO_ERROR,
@@ -1921,7 +1923,26 @@ contract LendingPoolConfigurator is VersionedInitializable, ILendingPoolConfigur
     _;
   }
 
-  uint256 internal constant CONFIGURATOR_REVISION = 0x2;
+  modifier onlyPoolOrEmergencyAdminOrProofOfReserve() {
+    require(
+      addressesProvider.getPoolAdmin() == msg.sender ||
+        addressesProvider.getEmergencyAdmin() == msg.sender ||
+        addressesProvider.getAddress('PROOF_OF_RESERVE_ADMIN') == msg.sender,
+      Errors.LPC_CALLER_NOT_POOL_OR_EMERGENCY_OR_PROOF_OF_RESERVE_ADMIN
+    );
+    _;
+  }
+
+  modifier onlyPoolOrProofOfReserveAdmin() {
+    require(
+      addressesProvider.getPoolAdmin() == msg.sender ||
+        addressesProvider.getAddress('PROOF_OF_RESERVE_ADMIN') == msg.sender,
+      Errors.LPC_CALLER_NOT_POOL_OR_PROOF_OF_RESERVE_ADMIN
+    );
+    _;
+  }
+
+  uint256 internal constant CONFIGURATOR_REVISION = 0x3;
 
   function getRevision() internal pure override returns (uint256) {
     return CONFIGURATOR_REVISION;
@@ -2132,7 +2153,7 @@ contract LendingPoolConfigurator is VersionedInitializable, ILendingPoolConfigur
    * @dev Disables borrowing on a reserve
    * @param asset The address of the underlying asset of the reserve
    **/
-  function disableBorrowingOnReserve(address asset) external onlyPoolAdmin {
+  function disableBorrowingOnReserve(address asset) external onlyPoolOrProofOfReserveAdmin {
     DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
 
     currentConfig.setBorrowingEnabled(false);
@@ -2212,7 +2233,7 @@ contract LendingPoolConfigurator is VersionedInitializable, ILendingPoolConfigur
    * @dev Disable stable rate borrowing on a reserve
    * @param asset The address of the underlying asset of the reserve
    **/
-  function disableReserveStableRate(address asset) external onlyPoolAdmin {
+  function disableReserveStableRate(address asset) external onlyPoolOrProofOfReserveAdmin {
     DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
 
     currentConfig.setStableRateBorrowingEnabled(false);
@@ -2257,7 +2278,7 @@ contract LendingPoolConfigurator is VersionedInitializable, ILendingPoolConfigur
    *  but allows repayments, liquidations, rate rebalances and withdrawals
    * @param asset The address of the underlying asset of the reserve
    **/
-  function freezeReserve(address asset) external onlyPoolOrEmergencyAdmin {
+  function freezeReserve(address asset) external onlyPoolOrEmergencyAdminOrProofOfReserve {
     DataTypes.ReserveConfigurationMap memory currentConfig = pool.getConfiguration(asset);
 
     currentConfig.setFrozen(true);
```
