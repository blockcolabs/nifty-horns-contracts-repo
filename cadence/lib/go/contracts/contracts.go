package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
	"strings"

	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts/internal/assets"
	_ "github.com/kevinburke/go-bindata"
)

const (
	niftyHornsFile                 = "NiftyHorns.cdc"
	marketFile                     = "NiftyHornsMarket.cdc"
	adminReceiverFile              = "NiftyHornsAdminReceiver.cdc"
	defaultNonFungibleTokenAddress = "NFTADDRESS"
	defaultFungibleTokenAddress    = "FUNGIBLETOKENADDRESS"
	defaultNiftyHornsAddress       = "NIFTYHORNSADDRESS"
	defaultMarketAddress           = "MARKETADDRESS"
)

// GenerateNiftyHornsContract returns a copy
// of the niftyHorns contract with the import addresses updated
func GenerateNiftyHornsContract(nftAddr string) []byte {

	niftyHornsCode := assets.MustAssetString(niftyHornsFile)

	codeWithNFTAddr := strings.ReplaceAll(niftyHornsCode, defaultNonFungibleTokenAddress, nftAddr)

	return []byte(codeWithNFTAddr)
}

// GenerateNiftyHornsAdminReceiverContract returns a copy
// of the NiftyHornsAdminReceiver contract with the import addresses updated
func GenerateNiftyHornsAdminReceiverContract(niftyHornsAddr string) []byte {

	adminReceiverCode := assets.MustAssetString(adminReceiverFile)
	codeWithNiftyHornsAddr := strings.ReplaceAll(adminReceiverCode, defaultNiftyHornsAddress, niftyHornsAddr)

	return []byte(codeWithShardedAddr)
}

// GenerateNiftyHornsMarketContract returns a copy
// of the NiftyHornsMarketContract with the import addresses updated
func GenerateNiftyHornsMarketContract(ftAddr, nftAddr, niftyHornsAddr) []byte {

	marketCode := assets.MustAssetString(marketFile)
	codeWithNFTAddr := strings.ReplaceAll(marketCode, defaultNonFungibleTokenAddress, nftAddr)
	codeWithNiftyHornsAddr := strings.ReplaceAll(codeWithNFTAddr, defaultNiftyHornsAddress, niftyHornsAddr)
	codeWithFTAddr := strings.ReplaceAll(codeWithNiftyHornsAddr, defaultFungibleTokenAddress, ftAddr)

	return []byte(codeWithNFTAddr)
}

// GenerateNiftyHornsMarketContract returns a copy
// of the third version NiftyHornsMarketContract with the import addresses updated
func GenerateNiftyHornsMarketContract(ftAddr, nftAddr, niftyHornsAddr, marketAddr) []byte {

	marketCode := assets.MustAssetString(marketFile)
	codeWithNFTAddr := strings.ReplaceAll(marketCode, defaultNonFungibleTokenAddress, nftAddr)
	codeWithNiftyHornsAddr := strings.ReplaceAll(codeWithNFTAddr, defaultNiftyHornsAddress, niftyHornsAddr)
	codeWithFTAddr := strings.ReplaceAll(codeWithNiftyHornsAddr, defaultFungibleTokenAddress, ftAddr)
	codeWithMarketAddr := strings.ReplaceAll(codeWithFTAddr, defaultMarketAddress, marketAddr)

	return []byte(codeWithMarketAddr)
}
