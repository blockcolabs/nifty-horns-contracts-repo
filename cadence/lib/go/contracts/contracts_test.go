package contracts_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts"
)

var addrA = "0A"
var addrB = "0B"
var addrC = "0C"
var addrD = "0D"
var addrE = "0E"

func TestNiftyHornsContract(t *testing.T) {
	contract := contracts.GenerateNiftyHornsContract(addrA)
	assert.Contains(t, string(contract), addrA)
	assert.NotNil(t, contract)
}

func TestNiftyHornsAdminReceiverContract(t *testing.T) {
	contract := contracts.GenerateNiftyHornsAdminReceiverContract(addrA)
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA)
}

func TestNiftyHornsMarketContract(t *testing.T) {
	contract := contracts.GenerateNiftyHornsMarketContract(addrA, addrB, addrC)
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA)
	assert.Contains(t, string(contract), addrB)
	assert.Contains(t, string(contract), addrC)
}
