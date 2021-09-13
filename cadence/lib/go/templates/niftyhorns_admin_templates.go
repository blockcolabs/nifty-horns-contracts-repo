package templates

import (
	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates/internal/assets"
)

const (
	transactionsPath       = "../../../transactions/"
	createCardTypeFilename = "admin/create_cardType.cdc"
	createDropFilename     = "admin/create_drop.cdc"
	addCardTypeFilename    = "admin/add_cardType_to_drop.cdc"
	addCardTypesFilename   = "admin/add_cardTypes_to_drop.cdc"
	lockDropFilename       = "admin/lock_drop.cdc"
	retireCardTypeFilename = "admin/retire_cardType_from_drop.cdc"
	retireAllFilename      = "admin/retire_all.cdc"
	newSeriesFilename      = "admin/start_new_series.cdc"
	mintCardFilename       = "admin/mint_card.cdc"
	batchMintCardFilename  = "admin/batch_mint_card.cdc"
	fulfillPackFilename    = "admin/fulfill_pack.cdc"

	transferAdminFilename = "admin/transfer_admin.cdc"
)

// GenerateMintCardTypeScript creates a new cardType data struct
// and initializes it with metadata
func GenerateMintCardTypeScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + createCardTypeFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateMintDropScript creates a new Drop struct and initializes its metadata
func GenerateMintDropScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + createDropFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateAddCardTypeToDropScript adds a cardType to a drop
// so that cards can be minted from the combo
func GenerateAddCardTypeToDropScript(env Environment) []byte {

	code := assets.MustAssetString(transactionsPath + addCardTypeFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateAddCardTypesToDropScript adds multiple cardTypes to a drop
func GenerateAddCardTypesToDropScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + addCardTypesFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateMintCardScript generates a script to mint a new card
// from a cardType-drop combination
func GenerateMintCardScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + mintCardFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateBatchMintCardScript mints multiple cards of the same cardType-drop combination
func GenerateBatchMintCardScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + batchMintCardFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateRetireCardTypeScript retires a cardType from a drop
func GenerateRetireCardTypeScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + retireCardTypeFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateRetireAllCardTypesScript retires all cardTypes from a drop
func GenerateRetireAllCardTypesScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + retireAllFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateLockDropScript locks a drop
func GenerateLockDropScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + lockDropFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateFulfillPackScript creates a script that fulfulls a pack
func GenerateFulfillPackScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + fulfillPackFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateTransferAdminScript generates a script to create and admin capability
// and transfer it to another account's admin receiver
func GenerateTransferAdminScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + transferAdminFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateChangeSeriesScript uses the admin to update the current series
func GenerateChangeSeriesScript(env Environment) []byte {
	code := assets.MustAssetString(transactionsPath + newSeriesFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateInvalidChangeCardTypesScript tries to modify the cardTypeDatas dictionary
// which should be invalid
func GenerateInvalidChangeCardTypesScript(env Environment) []byte {

	code := `
		import NiftyHorns from 0xNIFTYHORNSADDRESS

		transaction {
			prepare(acct: AuthAccount) {
				NiftyHorns.cardTypeDatas[UInt32(1)] = nil
			}
		}`
	return []byte(replaceAddresses(code, env))
}
