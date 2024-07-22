package keeper_test

import (
	_ "b-harvest/basechain/v1/x/csr/keeper"
	sdkmath "cosmossdk.io/math"
)

// params test suite
func (suite *KeeperTestSuite) TestParams() {
	params := suite.app.CSRKeeper.GetDefaultParams()
	// CSR is disabled by default
	suite.Require().False(params.EnableCsr)
	// Default CSRShares are 20%
	suite.Require().Equal(params.CsrShares, sdkmath.LegacyNewDecWithPrec(20, 2))
}
