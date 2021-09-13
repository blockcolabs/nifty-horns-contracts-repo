package templates

import (
	"fmt"
	"strings"

	_ "github.com/kevinburke/go-bindata"
)

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../transactions/... -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../transactions/...

const (
	placeholderFungibleTokenAddress      = "0xFUNGIBLETOKENADDRESS"
	placeholderFlowTokenAddress          = "0xFLOWTOKENADDRESS"
	placeholderNFTAddress                = "0xNFTADDRESS"
	placeholderNiftyHornsAddress         = "0xNIFTYHORNSADDRESS"
	placeholderNiftyHornsMarketAddress   = "0xMARKETADDRESS"
	placeholderAdminReceiverAddress      = "0xADMINRECEIVERADDRESS"
)

type Environment struct {
	Network                 string
	FungibleTokenAddress    string
	FlowTokenAddress        string
	NFTAddress              string
	NiftyHornsAddress       string
	NiftyHornsMarketAddress string
	ShardedAddress          string
	AdminReceiverAddress    string
}

func uint32ToCadenceArr(nums []uint32) []byte {
	var s string
	for _, n := range nums {
		s += fmt.Sprintf("%d as UInt32, ", n)
	}
	// slice the last 2 characters off as that's the comma and the whitespace
	return []byte("[" + s[:len(s)-2] + "]")
}

func withHexPrefix(address string) string {
	if address == "" {
		return ""
	}

	if address[0:2] == "0x" {
		return address
	}

	return fmt.Sprintf("0x%s", address)
}

func replaceAddresses(code string, env Environment) string {

	code = strings.ReplaceAll(
		code,
		placeholderFungibleTokenAddress,
		withHexPrefix(env.FungibleTokenAddress),
	)

	code = strings.ReplaceAll(
		code,
		placeholderFlowTokenAddress,
		withHexPrefix(env.FlowTokenAddress),
	)

	code = strings.ReplaceAll(
		code,
		placeholderNFTAddress,
		withHexPrefix(env.NFTAddress),
	)

	code = strings.ReplaceAll(
		code,
		placeholderNiftyHornsAddress,
		withHexPrefix(env.NiftyHornsAddress),
	)

	code = strings.ReplaceAll(
		code,
		placeholderNiftyHornsMarketAddress,
		withHexPrefix(env.NiftyHornsMarketAddress),
	)

	code = strings.ReplaceAll(
		code,
		placeholderAdminReceiverAddress,
		withHexPrefix(env.AdminReceiverAddress),
	)

	return code
}
