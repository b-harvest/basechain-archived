package govshuttle

import (
	"github.com/Canto-Network/Canto/v7/x/govshuttle/keeper"
	"github.com/Canto-Network/Canto/v7/x/govshuttle/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	authkeeper "github.com/cosmos/cosmos-sdk/x/auth/keeper"
	"github.com/ethereum/go-ethereum/common"
)

// InitGenesis initializes the govshuttle module's state from a provided genesis
// state.
func InitGenesis(ctx sdk.Context, k keeper.Keeper, accountKeeper authkeeper.AccountKeeper, genState types.GenesisState) {
	k.SetParams(ctx, genState.Params)

	if genState.PortContractAddr != "" {
		portAddr := common.HexToAddress(genState.PortContractAddr)
		k.SetPort(ctx, portAddr)
	}

	if acc := accountKeeper.GetModuleAccount(ctx, types.ModuleName); acc == nil {
		panic("the govshuttle module account has not been set")
	}
}

// ExportGenesis returns the govshuttle module's exported genesis.
func ExportGenesis(ctx sdk.Context, k keeper.Keeper) *types.GenesisState {
	genesis := types.DefaultGenesis()
	genesis.Params = k.GetParams(ctx)

	if portAddr, ok := k.GetPort(ctx); ok {
		genesis.PortContractAddr = portAddr.String()
	}

	return genesis
}
