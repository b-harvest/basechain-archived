package onboarding

import (
	sdk "github.com/cosmos/cosmos-sdk/types"

	"b-harvest/basechain/v1/x/onboarding/keeper"
	"b-harvest/basechain/v1/x/onboarding/types"
)

// InitGenesis import module genesis
func InitGenesis(
	ctx sdk.Context,
	k keeper.Keeper,
	data types.GenesisState,
) {
	k.SetParams(ctx, data.Params)
}

// ExportGenesis export module status
func ExportGenesis(ctx sdk.Context, k keeper.Keeper) *types.GenesisState {
	return &types.GenesisState{
		Params: k.GetParams(ctx),
	}
}
