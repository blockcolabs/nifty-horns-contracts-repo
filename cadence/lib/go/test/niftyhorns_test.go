package test

import (
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"

	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/contracts"
	"github.com/blockcolabs/nifty-horns-contracts-repo/cadence/lib/go/templates"

	"github.com/onflow/flow-go-sdk/crypto"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/stretchr/testify/assert"

	"github.com/onflow/flow-go-sdk"
)

const (
	NonFungibleTokenContractsBaseURL = "https://raw.githubusercontent.com/onflow/flow-nft/master/contracts/"
	NonFungibleTokenInterfaceFile    = "NonFungibleToken.cdc"

	emulatorFTAddress        = "ee82856bf20e2aa6"
	emulatorFlowTokenAddress = "0ae53cb6e3f42a79"
)

// This test is for testing the deployment the niftyHorns smart contracts
func TestNFTDeployment(t *testing.T) {
	b := newBlockchain()

	// Should be able to deploy the NFT contract
	// as a new account with no keys.
	nftCode, _ := DownloadFile(NonFungibleTokenContractsBaseURL + NonFungibleTokenInterfaceFile)
	nftAddr, err := b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NonFungibleToken",
			Source: string(nftCode),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// Should be able to deploy the niftyHorns contract
	// as a new account with no keys.
	niftyHornsCode := contracts.GenerateNiftyHornsContract(nftAddr.String())
	niftyHornsAddr, err := b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NiftyHorns",
			Source: string(niftyHornsCode),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// Should be able to deploy the admin receiver contract
	// as a new account with no keys.
	adminReceiverCode := contracts.GenerateNiftyHornsAdminReceiverContract(niftyHornsAddr.String())
	_, err = b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NiftyHornsAdminReceiver",
			Source: string(adminReceiverCode),
		},
	})
	if !assert.NoError(t, err) {
		t.Log(err.Error())
	}
	_, err = b.CommitBlock()
	assert.NoError(t, err)
}

// This test tests the pure functionality of the smart contract
func TestMintNFTs(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	env := templates.Environment{
		FungibleTokenAddress: emulatorFTAddress,
		FlowTokenAddress:     emulatorFlowTokenAddress,
	}

	// Should be able to deploy a contract as a new account with no keys.
	nftCode, _ := DownloadFile(NonFungibleTokenContractsBaseURL + NonFungibleTokenInterfaceFile)
	nftAddr, _ := b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NonFungibleToken",
			Source: string(nftCode),
		},
	})

	env.NFTAddress = nftAddr.String()

	// Deploy the niftyHorns contract
	niftyHornsCode := contracts.GenerateNiftyHornsContract(nftAddr.String())
	niftyHornsAccountKey, niftyHornsSigner := accountKeys.NewWithSigner()
	niftyHornsAddr, _ := b.CreateAccount([]*flow.AccountKey{niftyHornsAccountKey}, []sdktemplates.Contract{
		{
			Name:   "NiftyHorns",
			Source: string(niftyHornsCode),
		},
	})

	env.NiftyHornsAddress = niftyHornsAddr.String()

	// Check that that main contract fields were initialized correctly
	result := executeScriptAndCheck(t, b, templates.GenerateGetSeriesScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(0), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetNextCardTypeIDScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(1), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetNextDropIDScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(1), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetSupplyScript(env), nil)
	assert.Equal(t, cadence.NewUInt64(0), result)

	// Create a new user account
	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, _ := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	firstName := cadence.NewString("FullName")
	lebron := cadence.NewString("Lebron")
	oladipo := cadence.NewString("Oladipo")
	hayward := cadence.NewString("Hayward")
	durant := cadence.NewString("Durant")

	// Admin sends a transaction to create a cardType
	t.Run("Should be able to create a new CardType", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

		metadata := []cadence.KeyValuePair{{Key: firstName, Value: lebron}}
		cardType := cadence.NewDictionary(metadata)
		_ = tx.AddArgument(cardType)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
	})

	// Admin sends transactions to create multiple cardTypes
	t.Run("Should be able to create multiple new CardTypes", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

		metadata := []cadence.KeyValuePair{{Key: firstName, Value: oladipo}}
		cardType := cadence.NewDictionary(metadata)
		_ = tx.AddArgument(cardType)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

		metadata = []cadence.KeyValuePair{{Key: firstName, Value: hayward}}
		cardType = cadence.NewDictionary(metadata)
		_ = tx.AddArgument(cardType)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

		metadata = []cadence.KeyValuePair{{Key: firstName, Value: durant}}
		cardType = cadence.NewDictionary(metadata)
		_ = tx.AddArgument(cardType)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// Check that the return all cardTypes script doesn't fail
		// and that we can return metadata about the cardTypes
		executeScriptAndCheck(t, b, templates.GenerateGetAllCardTypesScript(env), nil)

		result = executeScriptAndCheck(t, b, templates.GenerateGetCardTypeMetadataFieldScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.String("FullName"))})
		assert.Equal(t, cadence.NewString("Lebron"), result)
	})

	// Admin creates a new Drop with the name Genesis
	t.Run("Should be able to create a new Drop", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateMintDropScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewString("Genesis"))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// Check that the drop name, ID, and series were initialized correctly.
		result := executeScriptAndCheck(t, b, templates.GenerateGetDropNameScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewString("Genesis"), result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetDropIDsByNameScript(env), [][]byte{jsoncdc.MustEncode(cadence.String("Genesis"))})
		idsArray := cadence.NewArray([]cadence.Value{cadence.NewUInt32(1)})
		assert.Equal(t, idsArray, result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetDropSeriesScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewUInt32(0), result)
	})

	// Admin sends a transaction that adds cardType 1 to the drop
	t.Run("Should be able to add a cardType to a Drop", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateAddCardTypeToDropScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(1))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
	})

	// Admin sends a transaction that adds cardTypes 2 and 3 to the drop
	t.Run("Should be able to add multiple cardTypes to a Drop", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateAddCardTypesToDropScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))

		cardTypes := []cadence.Value{cadence.NewUInt32(2), cadence.NewUInt32(3)}
		_ = tx.AddArgument(cadence.NewArray(cardTypes))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// Make sure the cardTypes were added correctly and the edition isn't retired or locked
		result := executeScriptAndCheck(t, b, templates.GenerateGetCardTypesInDropScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1))})
		cardTypesArray := cadence.NewArray([]cadence.Value{cadence.NewUInt32(1), cadence.NewUInt32(2), cadence.NewUInt32(3)})
		assert.Equal(t, cardTypesArray, result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetIsEditionRetiredScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewBool(false), result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetIsDropLockedScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewBool(false), result)

	})

	// Admin mints a card that stores it in the admin's collection
	t.Run("Should be able to mint a card", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// make sure the card was minted correctly and is stored in the collection with the correct data
		result := executeScriptAndCheck(t, b, templates.GenerateIsIDInCollectionScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr)), jsoncdc.MustEncode(cadence.UInt64(1))})
		assert.Equal(t, cadence.NewBool(true), result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetCollectionIDsScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr))})
		idsArray := cadence.NewArray([]cadence.Value{cadence.NewUInt64(1)})
		assert.Equal(t, idsArray, result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetCardDropScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr)), jsoncdc.MustEncode(cadence.UInt64(1))})
		assert.Equal(t, cadence.NewUInt32(1), result)
	})

	// Admin sends a transaction that locks the drop
	t.Run("Should be able to lock a drop which stops cardTypes from being added", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateLockDropScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// This should fail because the drop is locked
		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateAddCardTypeToDropScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(4))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			true,
		)

		// Script should return that the drop is locked
		result := executeScriptAndCheck(t, b, templates.GenerateGetIsDropLockedScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewBool(true), result)
	})

	// Admin sends a transaction that mints a batch of cards
	t.Run("Should be able to mint a batch of cards", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateBatchMintCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(3))
		_ = tx.AddArgument(cadence.NewUInt64(5))
		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// Ensure that the correct number of cards have been minted for each edition
		result := executeScriptAndCheck(t, b, templates.GenerateGetNumCardsInEditionScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewUInt32(1), result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetNumCardsInEditionScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.UInt32(3))})
		assert.Equal(t, cadence.NewUInt32(5), result)

		result = executeScriptAndCheck(t, b, templates.GenerateIsIDInCollectionScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr)), jsoncdc.MustEncode(cadence.UInt64(1))})
		assert.Equal(t, cadence.NewBool(true), result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetCollectionIDsScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr))})
		idsArray := cadence.NewArray([]cadence.Value{cadence.NewUInt64(1), cadence.NewUInt64(2), cadence.NewUInt64(3), cadence.NewUInt64(4), cadence.NewUInt64(5), cadence.NewUInt64(6)})
		assert.Equal(t, idsArray, result)

		result = executeScriptAndCheck(t, b, templates.GenerateGetCardDropScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(niftyHornsAddr)), jsoncdc.MustEncode(cadence.UInt64(1))})
		assert.Equal(t, cadence.NewUInt32(1), result)

	})

	t.Run("Should be able to mint a batch of cards and fulfill a pack", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateBatchMintCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(3))
		_ = tx.AddArgument(cadence.NewUInt64(5))
		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateFulfillPackScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		ids := []cadence.Value{cadence.NewUInt64(6), cadence.NewUInt64(7), cadence.NewUInt64(8)}
		_ = tx.AddArgument(cadence.NewArray(ids))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

	})

	// Admin sends a transaction to retire a cardType
	t.Run("Should be able to retire a CardType which stops minting", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateRetireCardTypeScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(1))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// Minting from this cardType should fail becuase it is retired
		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			true,
		)

		// Make sure this edition is retired
		result := executeScriptAndCheck(t, b, templates.GenerateGetIsEditionRetiredScript(env), [][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.UInt32(1))})
		assert.Equal(t, cadence.NewBool(true), result)
	})

	// Admin sends a transaction that retires all the cardTypes in a drop
	t.Run("Should be able to retire all CardTypes which stops minting", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateRetireAllCardTypesScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)

		// minting should fail
		tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewUInt32(1))
		_ = tx.AddArgument(cadence.NewUInt32(3))
		_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			true,
		)
	})

	// create a new Collection for a user address
	t.Run("Should be able to create a card Collection", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateSetupAccountScript(env), joshAddress)
		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, joshAddress}, []crypto.Signer{b.ServiceKey().Signer(), joshSigner},
			false,
		)
	})

	// Admin sends a transaction to transfer a card to a user
	t.Run("Should be able to transfer a card", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateTransferCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewAddress(joshAddress))
		_ = tx.AddArgument(cadence.NewUInt64(1))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
		// make sure the user received it
		result = executeScriptAndCheck(t, b, templates.GenerateIsIDInCollectionScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(joshAddress)), jsoncdc.MustEncode(cadence.UInt64(1))})
		assert.Equal(t, cadence.NewBool(true), result)
	})

	// Admin sends a transaction to transfer a batch of cards to a user
	t.Run("Should be able to batch transfer cards from a collection", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateBatchTransferCardScript(env), niftyHornsAddr)

		_ = tx.AddArgument(cadence.NewAddress(joshAddress))

		ids := []cadence.Value{cadence.NewUInt64(2), cadence.NewUInt64(3), cadence.NewUInt64(4)}
		_ = tx.AddArgument(cadence.NewArray(ids))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
		// make sure the user received them
		result = executeScriptAndCheck(t, b, templates.GenerateGetCardDropScript(env), [][]byte{jsoncdc.MustEncode(cadence.Address(joshAddress)), jsoncdc.MustEncode(cadence.UInt64(2))})
		assert.Equal(t, cadence.NewUInt32(1), result)
	})

	// Admin sends a transaction to update the current series
	t.Run("Should be able to change the current series", func(t *testing.T) {
		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateChangeSeriesScript(env), niftyHornsAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
	})

	// Make sure the contract fields are correct
	result = executeScriptAndCheck(t, b, templates.GenerateGetSeriesScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(1), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetNextCardTypeIDScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(5), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetNextDropIDScript(env), nil)
	assert.Equal(t, cadence.NewUInt32(2), result)

	result = executeScriptAndCheck(t, b, templates.GenerateGetSupplyScript(env), nil)
	assert.Equal(t, cadence.NewUInt64(11), result)

}

// This test is for ensuring that admin receiver smart contract works correctly
func TestTransferAdmin(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	env := templates.Environment{
		FungibleTokenAddress: emulatorFTAddress,
		FlowTokenAddress:     emulatorFlowTokenAddress,
	}

	// Should be able to deploy a contract as a new account with no keys.
	nftCode, _ := DownloadFile(NonFungibleTokenContractsBaseURL + NonFungibleTokenInterfaceFile)
	nftAddr, _ := b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NonFungibleToken",
			Source: string(nftCode),
		},
	})

	env.NFTAddress = nftAddr.String()

	// First, deploy the niftyHorns contract
	niftyHornsCode := contracts.GenerateNiftyHornsContract(nftAddr.String())
	niftyHornsAccountKey, niftyHornsSigner := accountKeys.NewWithSigner()
	niftyHornsAddr, _ := b.CreateAccount([]*flow.AccountKey{niftyHornsAccountKey}, []sdktemplates.Contract{
		{
			Name:   "NiftyHorns",
			Source: string(niftyHornsCode),
		},
	})

	env.NiftyHornsAddress = niftyHornsAddr.String()

	// Should be able to deploy the admin receiver contract
	adminReceiverCode := contracts.GenerateNiftyHornsAdminReceiverContract(niftyHornsAddr.String())
	adminAccountKey, adminSigner := accountKeys.NewWithSigner()
	adminAddr, _ := b.CreateAccount([]*flow.AccountKey{adminAccountKey}, []sdktemplates.Contract{
		{
			Name:   "NiftyHornsAdminReceiver",
			Source: string(adminReceiverCode),
		},
	})
	b.CommitBlock()

	env.AdminReceiverAddress = adminAddr.String()

	firstName := cadence.NewString("FullName")
	lebron := cadence.NewString("Lebron")

	// create a new Collection
	t.Run("Should be able to transfer an admin Capability to the receiver account", func(t *testing.T) {

		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateTransferAdminScript(env), niftyHornsAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
			false,
		)
	})

	// can create a new cardType with the new admin
	t.Run("Should be able to create a new CardType with the new Admin account", func(t *testing.T) {

		tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), adminAddr)

		metadata := []cadence.KeyValuePair{{Key: firstName, Value: lebron}}
		cardType := cadence.NewDictionary(metadata)
		_ = tx.AddArgument(cardType)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{b.ServiceKey().Address, adminAddr}, []crypto.Signer{b.ServiceKey().Signer(), adminSigner},
			false,
		)
	})
}

func TestDropCardTypesOwnedByAddressScript(t *testing.T) {
	// Setup
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	env := templates.Environment{
		FungibleTokenAddress: emulatorFTAddress,
		FlowTokenAddress:     emulatorFlowTokenAddress,
	}

	// Should be able to deploy a contract as a new account with no keys.
	nftCode, _ := DownloadFile(NonFungibleTokenContractsBaseURL + NonFungibleTokenInterfaceFile)
	nftAddr, _ := b.CreateAccount(nil, []sdktemplates.Contract{
		{
			Name:   "NonFungibleToken",
			Source: string(nftCode),
		},
	})

	env.NFTAddress = nftAddr.String()

	// First, deploy the niftyHorns contract
	niftyHornsCode := contracts.GenerateNiftyHornsContract(nftAddr.String())
	niftyHornsAccountKey, niftyHornsSigner := accountKeys.NewWithSigner()
	niftyHornsAddr, _ := b.CreateAccount([]*flow.AccountKey{niftyHornsAccountKey}, []sdktemplates.Contract{
		{
			Name:   "NiftyHorns",
			Source: string(niftyHornsCode),
		},
	})

	env.NiftyHornsAddress = niftyHornsAddr.String()

	// Create a new user account
	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, _ := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	// Create card collection
	tx := createTxWithTemplateAndAuthorizer(b, templates.GenerateSetupAccountScript(env), joshAddress)
	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, joshAddress}, []crypto.Signer{b.ServiceKey().Signer(), joshSigner},
		false,
	)

	firstName := cadence.NewString("FullName")
	lebron := cadence.NewString("Lebron")
	hayward := cadence.NewString("Hayward")
	antetokounmpo := cadence.NewString("Antetokounmpo")

	// Create cardTypes
	lebronCardTypeID := uint32(1)
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

	metadata := []cadence.KeyValuePair{{Key: firstName, Value: lebron}}
	cardType := cadence.NewDictionary(metadata)
	_ = tx.AddArgument(cardType)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)
	haywardCardTypeID := uint32(2)
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

	metadata = []cadence.KeyValuePair{{Key: firstName, Value: hayward}}
	cardType = cadence.NewDictionary(metadata)
	_ = tx.AddArgument(cardType)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)
	antetokounmpoCardTypeID := uint32(3)
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardTypeScript(env), niftyHornsAddr)

	metadata = []cadence.KeyValuePair{{Key: firstName, Value: antetokounmpo}}
	cardType = cadence.NewDictionary(metadata)
	_ = tx.AddArgument(cardType)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)

	// Create Drop
	genesisDropID := uint32(1)
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintDropScript(env), niftyHornsAddr)

	_ = tx.AddArgument(cadence.NewString("Genesis"))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)

	// Add cardTypes to Drop
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateAddCardTypesToDropScript(env), niftyHornsAddr)

	_ = tx.AddArgument(cadence.NewUInt32(genesisDropID))

	cardTypes := []cadence.Value{cadence.NewUInt32(lebronCardTypeID), cadence.NewUInt32(haywardCardTypeID), cadence.NewUInt32(antetokounmpoCardTypeID)}
	_ = tx.AddArgument(cadence.NewArray(cardTypes))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)

	// Mint two cards to joshAddress
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

	_ = tx.AddArgument(cadence.NewUInt32(genesisDropID))
	_ = tx.AddArgument(cadence.NewUInt32(lebronCardTypeID))
	_ = tx.AddArgument(cadence.NewAddress(joshAddress))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

	_ = tx.AddArgument(cadence.NewUInt32(genesisDropID))
	_ = tx.AddArgument(cadence.NewUInt32(haywardCardTypeID))
	_ = tx.AddArgument(cadence.NewAddress(joshAddress))
	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)

	// Mint one card to niftyHornsAddress
	tx = createTxWithTemplateAndAuthorizer(b, templates.GenerateMintCardScript(env), niftyHornsAddr)

	_ = tx.AddArgument(cadence.NewUInt32(genesisDropID))
	_ = tx.AddArgument(cadence.NewUInt32(lebronCardTypeID))
	_ = tx.AddArgument(cadence.NewAddress(niftyHornsAddr))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, niftyHornsAddr}, []crypto.Signer{b.ServiceKey().Signer(), niftyHornsSigner},
		false,
	)

	t.Run("Should return true if the address owns cards corresponding to each DropCardType", func(t *testing.T) {
		script := templates.GenerateDropCardTypesOwnedByAddressScript(env)

		dropIDs := cadence.NewArray([]cadence.Value{cadence.NewUInt32(genesisDropID), cadence.NewUInt32(genesisDropID)})
		cardTypeIDs := cadence.NewArray([]cadence.Value{cadence.NewUInt32(lebronCardTypeID), cadence.NewUInt32(haywardCardTypeID)})

		result := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.Address(joshAddress)), jsoncdc.MustEncode(dropIDs), jsoncdc.MustEncode(cardTypeIDs)})

		assert.Equal(t, cadence.NewBool(true), result)
	})

	t.Run("Should return false if the address does not own cards corresponding to each DropCardType", func(t *testing.T) {
		script := templates.GenerateDropCardTypesOwnedByAddressScript(env)

		dropIDs := cadence.NewArray([]cadence.Value{cadence.NewUInt32(genesisDropID), cadence.NewUInt32(genesisDropID), cadence.NewUInt32(genesisDropID)})
		cardTypeIDs := cadence.NewArray([]cadence.Value{cadence.NewUInt32(lebronCardTypeID), cadence.NewUInt32(haywardCardTypeID), cadence.NewUInt32(antetokounmpoCardTypeID)})

		result := executeScriptAndCheck(t, b, script, [][]byte{jsoncdc.MustEncode(cadence.Address(joshAddress)), jsoncdc.MustEncode(dropIDs), jsoncdc.MustEncode(cardTypeIDs)})
		assert.Equal(t, cadence.NewBool(false), result)
	})

	// t.Run("Should fail with mismatched Drop and CardType slice lengths", func(t *testing.T) {
	// 	_, err := templates.GenerateDropCardTypesOwnedByAddressScript(niftyHornsAddr, joshAddress, []uint32{1, 2}, []uint32{1})
	// 	assert.Error(t, err)
	// 	assert.True(t, strings.Contains(err.Error(), "mismatched lengths"))
	// })

	// t.Run("Should fail with empty DropCardTypes", func(t *testing.T) {
	// 	_, err := templates.GenerateDropCardTypesOwnedByAddressScript(niftyHornsAddr, joshAddress, []uint32{}, []uint32{})
	// 	assert.Error(t, err)
	// 	assert.True(t, strings.Contains(err.Error(), "no DropCardTypes"))
	// })
}
