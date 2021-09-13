package templates

import (
	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates/internal/assets"
)

const (
	createSaleFilename          = "market/create_sale.cdc"
	startSaleFilename           = "market/start_sale.cdc"
	createAndStartSaleFilename  = "market/create_start_sale.cdc"
	withdrawSaleFilename        = "market/stop_sale.cdc"
	changePriceFilename         = "market/change_price.cdc"
	changeOwnerReceiverFilename = "market/change_receiver.cdc"
	purchaseFilename            = "market/purchase_card.cdc"
	mintAndPurchaseFilename     = "market/mint_and_purchase.cdc"
	upgradeSaleFilename         = "market/upgrade_sale.cdc"

	purchaseBothMarketsFilename = "market/purchase_both_markets.cdc"

	// scripts
	getSalePriceFilename      = "market/scripts/get_sale_price.cdc"
	getSalePercentageFilename = "market/scripts/get_sale_percentage.cdc"
	getSaleLengthFilename     = "market/scripts/get_sale_len.cdc"
	getSaleDropIDFilename     = "market/scripts/get_sale_drop_id.cdc"
)

// This contains template transactions for the third version of the Nifty Horns
// marketplace, which uses a capability to access the owner's card collection
// instead of storing the cards in the sale collection directly

// GenerateCreateSaleScript creates a cadence transaction that creates a Sale collection
// and stores in in the callers account published
func GenerateCreateSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + createSaleFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateStartSaleScript creates a cadence transaction that starts a sale by setting the price for the NFT
func GenerateStartSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + startSaleFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateCreateAndStartSaleScript creates a cadence transaction that creates a Sale collection
// and stores in in the callers account, and also puts an NFT up for sale in it
func GenerateCreateAndStartSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + createAndStartSaleFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateCancelSaleScript creates a cadence transaction that ends a sale by clearing its price
func GenerateCancelSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + withdrawSaleFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateChangePriceScript creates a cadence transaction that changes the price on an existing sale
func GenerateChangePriceScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + changePriceFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateChangeOwnerReceiverScript creates a cadence transaction
// that changes the sellers receiver capability
func GenerateChangeOwnerReceiverScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + changeOwnerReceiverFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateBuySaleScript creates a cadence transaction that makes a purchase of
// an existing sale
func GenerateBuySaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + purchaseFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateMintTokensAndBuyScript creates a script that uses the admin resource
// from the admin accountto mint new tokens and use them to purchase a Nifty Horns
// card from a market collection
func GenerateMintTokensAndBuyScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + mintAndPurchaseFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateUpgradeSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + upgradeSaleFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateMultiContractP2PPurchaseScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + purchaseBothMarketsFilename)

	return []byte(replaceAddresses(code, env))
}

/***************  SCRIPTS **************************/

// GenerateGetSalePriceScript creates a script that retrieves a sale collection
// and returns the price of the specified card
func GenerateGetSalePriceScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + getSalePriceFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetSalePercentageScript creates a script that retrieves a sale collection
// from storage and returns the cut percentage
func GenerateGetSalePercentageScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + getSalePercentageFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetSaleLenScript creates a script that retrieves an NFT collection
// reference and returns its length
func GenerateGetSaleLenScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + getSaleLengthFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetSaleDropIDScript creates a script that checks
// a sale for a certain ID and returns its drop ID
func GenerateGetSaleDropIDScript(env Environment) []byte {

	code := assets.MustAssetString(transactionsPath + getSaleDropIDFilename)

	return []byte(replaceAddresses(code, env))
}
