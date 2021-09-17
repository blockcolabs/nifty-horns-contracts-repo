package templates

import (
	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates/internal/assets"
)

const (
	scriptsPath = "../../../transactions/scripts/"

	// Nifty Horns contract scripts
	currentSeriesFilename = "get_currentSeries.cdc"
	totalSupplyFilename   = "get_totalSupply.cdc"

	// CardType related scripts
	getAllCardTypesFilename = "cardTypes/get_all_cardTypes.cdc"
	nextCardTypeIDFilename  = "cardTypes/get_nextCardTypeID.cdc"
	cardTypeMetadata        = "cardTypes/get_cardType_metadata.cdc"
	cardTypeMetadataField   = "cardTypes/get_cardType_metadata_field.cdc"

	// Drop related scripts
	editionRetiredFilename    = "drops/get_edition_retired.cdc"
	numCardsInEditionFilename = "drops/get_numCards_in_edition.cdc"
	dropIDsByNameFilename     = "drops/get_dropIDs_by_name.cdc"
	dropSeriesFilename        = "drops/get_dropSeries.cdc"
	nextDropIDFilename        = "drops/get_nextDropID.cdc"
	cardTypesInDropFilename   = "drops/get_cardTypes_in_drop.cdc"
	dropNameFilename          = "drops/get_dropName.cdc"
	dropLockedFilename        = "drops/get_drop_locked.cdc"

	// collections scripts
	collectionIDsFilename            = "collections/get_collection_ids.cdc"
	metadataFieldFilename            = "collections/get_metadata_field.cdc"
	cardSeriesFilename               = "collections/get_card_series.cdc"
	idInCollectionFilename           = "collections/get_id_in_Collection.cdc"
	cardCardTypeIDFilename           = "collections/get_card_cardTypeID.cdc"
	cardDropIDFilename               = "collections/get_card_dropID.cdc"
	metadataFilename                 = "collections/get_metadata.cdc"
	cardSerialNumFilename            = "collections/get_card_serialNum.cdc"
	cardDropNameFilename             = "collections/get_card_dropName.cdc"
	getDropCardTypesAreOwnedFilename = "collections/get_dropcardTypes_are_owned.cdc"
)

// Global Data Gettetrs

func GenerateGetSeriesScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + currentSeriesFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetSupplyScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + totalSupplyFilename)

	return []byte(replaceAddresses(code, env))
}

// CardType Related Scripts

func GenerateGetAllCardTypesScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + getAllCardTypesFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetNextCardTypeIDScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + nextCardTypeIDFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardTypeMetadataScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardTypeMetadata)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardTypeMetadataFieldScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardTypeMetadataField)

	return []byte(replaceAddresses(code, env))
}

// Drop-related scripts

// GenerateGetIsEditionRetiredScript creates a script that indicates if an edition is retired
func GenerateGetIsEditionRetiredScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + editionRetiredFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetNumCardsInEditionScript creates a script
// that returns the number of cards that have been minted in an edition
func GenerateGetNumCardsInEditionScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + numCardsInEditionFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetDropIDsByNameScript creates a script that returns dropIDs that share a name
func GenerateGetDropIDsByNameScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + dropIDsByNameFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetDropNameScript creates a script that returns the name of a drop
func GenerateGetDropNameScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + dropNameFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetDropSeriesScript creates a script that returns the metadata of a cardType
func GenerateGetDropSeriesScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + dropSeriesFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetNextDropIDScript creates a script that returns next drop ID that will be used
func GenerateGetNextDropIDScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + nextDropIDFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetCardTypesInDropScript creates a script that returns an array of cardTypes in a drop
func GenerateGetCardTypesInDropScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardTypesInDropFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateGetIsDropLockedScript creates a script that indicates if a drop is locked
func GenerateGetIsDropLockedScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + dropLockedFilename)

	return []byte(replaceAddresses(code, env))
}

// Collection related scripts

func GenerateGetCollectionIDsScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + collectionIDsFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardMetadataScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + metadataFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardMetadataFieldScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + metadataFieldFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardSeriesScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardSeriesFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateIsIDInCollectionScript creates a script that checks
// a collection for a certain ID
func GenerateIsIDInCollectionScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + idInCollectionFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardCardTypeScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardCardTypeIDFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardDropScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardDropIDFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardDropNameScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardDropNameFilename)

	return []byte(replaceAddresses(code, env))
}

func GenerateGetCardSerialNumScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + cardSerialNumFilename)

	return []byte(replaceAddresses(code, env))
}

// GenerateDropCardTypesOwnedByAddressScript generates a script that returns true if each of the DropCardTypes corresponding to
// the passed Drop and CardType IDs are owned by the passed flow.Address.
//
// Drop and CardType IDs are matched up by index in the passed slices.
func GenerateDropCardTypesOwnedByAddressScript(env Environment) []byte {
	code := assets.MustAssetString(scriptsPath + getDropCardTypesAreOwnedFilename)

	return []byte(replaceAddresses(code, env))
}
