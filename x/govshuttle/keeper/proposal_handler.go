package keeper

import (
	"github.com/Canto-Network/Canto/v7/x/govshuttle/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
	govtypes "github.com/cosmos/cosmos-sdk/x/gov/types"
)

// Return governance handler to process Compound Proposal
func NewgovshuttleProposalHandler(k *Keeper) govtypes.Handler {
	return func(ctx sdk.Context, content govtypes.Content) error {
		switch c := content.(type) {
		case *types.LendingMarketProposal:
			return handleLendingMarketProposal(ctx, k, c)

		case *types.TreasuryProposal:
			return handleTreasuryProposal(ctx, k, c)
		default:
			return sdkerrors.Wrapf(sdkerrors.ErrUnknownRequest, "unrecognized %s proposal content type: %T", types.ModuleName, c)
		}
	}
}

func handleLendingMarketProposal(ctx sdk.Context, k *Keeper, p *types.LendingMarketProposal) error {
	err := p.ValidateBasic()
	if err != nil {
		return err
	}
	_, err = k.AppendLendingMarketProposal(ctx, p) //Defined analogous to (erc20)k.RegisterCoin
	if err != nil {
		return err
	}

	return nil
}

// governance proposal handler
func handleTreasuryProposal(ctx sdk.Context, k *Keeper, tp *types.TreasuryProposal) error {
	err := tp.ValidateBasic()
	if err != nil {
		return err
	}
	lm := tp.FromTreasuryToLendingMarket()
	_, err = k.AppendLendingMarketProposal(ctx, lm)
	tp.GetMetadata().PropID = lm.GetMetadata().GetPropId()
	if err != nil {
		return err
	}

	return nil
}
