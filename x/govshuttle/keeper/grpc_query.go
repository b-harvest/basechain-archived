package keeper

import (
	"b-harvest/basechain/v1/x/govshuttle/types"
)

var _ types.QueryServer = Keeper{}
