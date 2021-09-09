import NiftyHorns from 0xNIFTYHORNSADDRESS

// This script checks whether for each DropID/CardTypeID combo,
// they own a card matching that DropCardType.

// Parameters:
//
// account: The Flow Address of the account whose card data needs to be read
// dropIDs: A list of unique IDs for the drops whose data needs to be read
// cardTypeIDs: A list of unique IDs for the cardTypes whose data needs to be read

// Returns: Bool
// Whether for each DropID/CardTypeID combo,
// account owns a card matching that DropCardType.

pub fun main(account: Address, dropIDs: [UInt32], cardTypeIDs: [UInt32]): Bool {

    assert(
        dropIDs.length == cardTypeIDs.length,
        message: "drop and cardType ID arrays have mismatched lengths"
    )

    let collectionRef = getAccount(account).getCapability(/public/CardCollection)
                .borrow<&{NiftyHorns.CardCollectionPublic}>()
                ?? panic("Could not get public card collection reference")

    let cardIDs = collectionRef.getIDs()

    // For each DropID/CardTypeID combo, loop over each card in the account
    // to see if they own a card matching that DropCardType.
    var i = 0

    while i < dropIDs.length {
        var hasMatchingCard = false
        for cardID in cardIDs {
            let token = collectionRef.borrowCard(id: cardID)
                ?? panic("Could not borrow a reference to the specified card")

            let cardData = token.data
            if cardData.dropID == dropIDs[i] && cardData.cardTypeID == cardTypeIDs[i] {
                hasMatchingCard = true
                break
            }
        }
        if !hasMatchingCard {
            return false
        }
        i = i + 1
    }

    return true
}