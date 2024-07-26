package ante

import (
	"github.com/cosmos/cosmos-sdk/codec"
	sdk "github.com/cosmos/cosmos-sdk/types"

	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
	stakingtypes "github.com/cosmos/cosmos-sdk/x/staking/types"
)

var minCommission = sdk.NewDecWithPrec(5, 2) // 5%

// TODO: remove once Cosmos SDK is upgraded to v0.46

// ValidatorCommissionDecorator validates that the validator commission is always
// greater or equal than the min commission rate
type ValidatorCommissionDecorator struct {
	cdc codec.BinaryCodec
}

// NewValidatorCommissionDecorator creates a new NewValidatorCommissionDecorator
func NewValidatorCommissionDecorator(cdc codec.BinaryCodec) ValidatorCommissionDecorator {
	return ValidatorCommissionDecorator{
		cdc: cdc,
	}
}

// AnteHandle checks if the tx contains a staking create validator or edit validator.
// It errors if the the commission rate is below the min threshold.
func (vcd ValidatorCommissionDecorator) AnteHandle(ctx sdk.Context, tx sdk.Tx, simulate bool, next sdk.AnteHandler) (newCtx sdk.Context, err error) {
	for _, msg := range tx.GetMsgs() {
		if err := vcd.validateMsg(ctx, msg); err != nil {
			return ctx, err
		}
	}
	return next(ctx, tx, simulate)
}

// validateMsg checks that the commission rate is over 5% for create and edit validator msgs
func (vcd ValidatorCommissionDecorator) validateMsg(_ sdk.Context, msg sdk.Msg) error {
	switch msg := msg.(type) {
	case *stakingtypes.MsgCreateValidator:
		if msg.Commission.Rate.LT(minCommission) {
			return sdkerrors.Wrapf(
				sdkerrors.ErrInvalidRequest,
				"validator commission %s be lower than minimum of %s", msg.Commission.Rate, minCommission)
		}
	case *stakingtypes.MsgEditValidator:
		if msg.CommissionRate != nil && msg.CommissionRate.LT(minCommission) {
			return sdkerrors.Wrapf(
				sdkerrors.ErrInvalidRequest,
				"validator commission %s be lower than minimum of %s", msg.CommissionRate, minCommission)
		}
	}
	return nil
}
