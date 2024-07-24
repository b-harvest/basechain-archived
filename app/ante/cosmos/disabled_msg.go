package cosmos

import (
	"fmt"

	errorsmod "cosmossdk.io/errors"
	sdk "github.com/cosmos/cosmos-sdk/types"
	errortypes "github.com/cosmos/cosmos-sdk/types/errors"
)

// DisabledMsgsDecorator blocks certain msg types from being granted or executed
// within the authorization module.
type DisabledMsgsDecorator struct {
	// disabledMsgTypes is the type urls of the msgs to block.
	disabledMsgTypes []string
}

// NewDisabledMsgDecorator creates a decorator to block certain msg types
func NewDisabledMsgDecorator(disabledMsgTypes ...string) DisabledMsgsDecorator {
	return DisabledMsgsDecorator{
		disabledMsgTypes: disabledMsgTypes,
	}
}

func (ald DisabledMsgsDecorator) AnteHandle(ctx sdk.Context, tx sdk.Tx, simulate bool, next sdk.AnteHandler) (newCtx sdk.Context, err error) {
	if err := ald.checkDisabledMsgs(tx.GetMsgs()); err != nil {
		return ctx, errorsmod.Wrapf(errortypes.ErrUnauthorized, err.Error())
	}
	return next(ctx, tx, simulate)
}

// checkDisabledMsgs iterates through the msgs and returns an error if it finds any unauthorized msgs.
func (ald DisabledMsgsDecorator) checkDisabledMsgs(msgs []sdk.Msg) error {
	for _, msg := range msgs {
		url := sdk.MsgTypeURL(msg)
		if ald.isDisabledMsg(url) {
			return fmt.Errorf("found disabled msg type: %s", url)
		}
	}
	return nil
}

// isDisabledMsg returns true if the given message is in the list of restricted
// messages from the AnteHandler.
func (ald DisabledMsgsDecorator) isDisabledMsg(msgTypeURL string) bool {
	for _, disabledType := range ald.disabledMsgTypes {
		if msgTypeURL == disabledType {
			return true
		}
	}

	return false
}
