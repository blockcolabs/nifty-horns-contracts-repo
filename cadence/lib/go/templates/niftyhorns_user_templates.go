package templates

import (
	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates/internal/assets"
)

const (
	setupAccountFilename  = "user/setup_account.cdc"
	transferCardFilename  = "user/transfer_card.cdc"
	batchTransferFilename = "user/batch_transfer.cdc"

	transferCardSaleFilename  = "user/transfer_card_sale.cdc"
)

// GenerateSetupAccountScript creates a script that drops up an account to use Nifty Horns
func GenerateSetupAccountScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + setupAccountFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateTransferCardScript creates a script that transfers a card
func GenerateTransferCardScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + transferCardFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateBatchTransferCardScript creates a script that transfers multiple cards
func GenerateBatchTransferCardScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + batchTransferFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateTransferCardSaleScript creates a script that transfers a card
// and cancels its sale if it is for sale
func GenerateTransferCardSaleScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + transferCardSaleFilename)

	return []byte(replaceAddresses(code, env))
}
