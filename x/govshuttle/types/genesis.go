package types

// DefaultGenesis returns the default Capability genesis state
func DefaultGenesis() *GenesisState {
	return NewGenesisState(DefaultParams(), "")
}

func NewGenesisState(params Params, portContractAddr string) *GenesisState {
	return &GenesisState{
		Params:           params,
		PortContractAddr: portContractAddr,
	}
}

// Validate performs basic genesis state validation returning an error upon any
// failure.
func (gs GenesisState) Validate() error {
	// this line is used by starport scaffolding # genesis/types/validate

	return gs.Params.Validate()
}
