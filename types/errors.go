package types

import (
	errorsmod "cosmossdk.io/errors"
)

// RootCodespace is the codespace for all errors defined in this package
const RootCodespace = "basechain"

// root error codes for basechain
const (
	codeKeyTypeNotSupported = iota + 2
)

// errors
var (
	ErrKeyTypeNotSupported = errorsmod.Register(RootCodespace, codeKeyTypeNotSupported, "key type 'secp256k1' not supported")
)
