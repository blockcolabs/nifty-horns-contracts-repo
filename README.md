# nifty-horns-contracts-repo
Smart contracts for Nifty Horns

## Directory Structure

The directories here are organized into contracts, scripts, and transactions.

Contracts contain the source code for the Nifty Horns contracts that are deployed to Flow.

Scripts contain read-only transactions to get information about
the state of someone's Collection or about the state of the Nifty Hornscontract.

Transactions contain the transactions that various admins and users can use
to perform actions in the smart contract like creating cardTypes and drops,
minting Cards, and transfering Cards.

 - `contracts/` : Where the Nifty Horns related smart contracts live.
 - `transactions/` : This directory contains all the transactions and scripts
 that are associated with the Nifty Horns smart contracts.
 - `transactions/scripts/`  : This contains all the read-only Cadence scripts
 that are used to read information from the smart contract
 or from a resource in account storage.
 - `lib/` : This directory contains packages for specific programming languages
 to be able to read copies of the Nifty Horns smart contracts, transaction templates,
 and scripts. Also contains automated tests written in those languages. See the
 README in `lib/go/` for more information about how to use the Go packages.

## Nifty Horns Contract Overview

Each Nifty Horns Card NFT represents a cardType for a specific athlete..
CardTypes are grouped into drops which usually have some overarching theme,
like rarity or the type of the cardType.

A drop can have one or more cardTypes in it and the same cardType can exist in
multiple drops, but the combination of a cardType and a drop,
otherwise known as an edition, is unique and is what classifies an individual Card.

Multiple Cards can be minted from the same edition and each receives a
serial number that indicates where in the edition it was minted.

Each Card is a resource object
with roughly the following structure:

```cadence
pub resource Card {

    // global unique Card ID
    pub let id: UInt64

    // the ID of the Drop that the Card comes from
    pub let dropID: UInt32

    // the ID of the CardType that the Card references
    pub let cardTypeID: UInt32

    // the place in the edition that this Card was minted
    // Otherwise know as the serial number
    pub let serialNumber: UInt32
}
```

The other types that are defined in `NiftyHorns` are as follows:

 - `CardType`: A struct type that holds most of the metadata for the Cards.
    All cardTypes in Nifty Horns will be stored and modified in the main contract.
 - `DropData`: A struct that contains constant information about drops in Nifty Horns
    like the name, the series, the id, and such.
 - `Drop`: A resource that contains variable data for drops
    and the functionality to modify drops,
    like adding and retiring cardTypes, locking the drop, and minting Cards from
    the drop.
 - `CardData`: A struct that contains the metadata associated with a Card.
    instances of it will be stored in each Card.
 - `NFT`: A resource type that is the NFT that represents the Card
    highlight a user owns. It stores its unique ID and other metadata. This
    is the collectible object that the users store in their accounts.
 - `Collection`: Similar to the `NFTCollection` resource from the NFT
    example, this resource is a repository for a user's Cards.  Users can
    withdraw and deposit from this collection and get information about the
    contained Cards.
 - `Admin`: This is a resource type that can be used by admins to perform
    various acitions in the smart contract like starting a new series,
    creating a new cardType or drop, and getting a reference to an existing drop.

Metadata structs associated with cardTypes and drops are stored in the main smart contract
and can be queried by anyone. For example, If a cardTypeer wanted to find out the
name of the team that the cardTypeer represented in their Card cardTypes for, they
would call a public function in the `NiftyHorns` smart contract
called `getCardTypeMetaDataByField`, providing, from their owned Card,
the cardType and field that they want to query.
They can do the same with information about drops.

The power to create new cardTypes, drops, and Cards rests
with the owner of the `Admin` resource.

Admins create cardTypes and drops which are stored in the main smart contract,
Admins can add cardTypes to drops to create editions, which Cards can be minted from.

Admins also can restrict the abilities of drops and editions to be further expanded.
A drop begins as being unlocked, which means cardTypes can be added to it,
but when an admin locks the drop, cardTypes can no longer be added to it.
This cannot be reversed.

The same applies to editions. Editions start out open, and an admin can mint as
many Cards they want from the edition. When an admin retires the edition,
Cards can no longer be minted from that edition. This cannot be reversed.

These rules are in place to ensure the scarcity of drops and editions
once they are closed.

Once a user owns a Card object, that Card is stored directly
in their account storage via their `Collection` object. The collection object
contains a dictionary that stores the Cards and gives utility functions
to move them in and out and to read data about the collection and its Cards.

## Instructions for creating cardTypes and minting cards

A common order of creating new Cards would be

1. Creating new cardTypes with `transactions/admin/create_cardType.cdc`.
2. Creating new drops with `transactions/admin/create_drop.cdc`.
3. Adding cardTypes to the drops to create editions
   with `transactions/admin/add_cardTypes_to_drop.cdc`.
4. Minting Cards from those editions with
   `transactions/admin/batch_mint_card.cdc`.

You can also see the scripts in `transactions/scripts` to see how information
can be read from the real Nifty Horns smart contract.

## Nifty Horns Events

The smart contract and its various resources will emit certain events
that show when specific actions are taken, like transferring an NFT. This
is a list of events that can be emitted, and what each event means.
You can find definitions for interpreting these events in Go by seeing
the `lib/go/events` package.

- `pub event ContractInitialized()`

    This event is emitted when the `NiftyHorns` contract is created.

#### Events for cardTypes
- `pub event CardTypeCreated(id: UInt32, metadata: {String:String})`

    Emitted when a new cardType has been created and added to the smart contract by an admin.

- `pub event NewSeriesStarted(newCurrentSeries: UInt32)`

    Emitted when a new series has been triggered by an admin.

#### Events for drop-Related actions

- `pub event DropCreated(dropID: UInt32, series: UInt32)`

    Emitted when a new drop is created.

- `pub event CardTypeAddedToDrop(dropID: UInt32, cardTypeID: UInt32)`

    Emitted when a new cardType is added to a drop.

- `pub event CardTypeRetiredFromDrop(dropID: UInt32, cardTypeID: UInt32, numCards: UInt32)`

    Emitted when a cardType is retired from a drop. Indicates that
    that cardType/drop combination and cannot be used to mint cards any more.

- `pub event DropLocked(dropID: UInt32)`

    Emitted when a drop is locked, meaning cardTypes cannot be added.

- `pub event CardMinted(cardID: UInt64, cardTypeID: UInt32, dropID: UInt32, serialNumber: UInt32)`

    Emitted when a Card is minted from a drop. The `cardID` is the global unique identifier that differentiates a Card from all other Nifty Horns Cards in existence. The `serialNumber` is the identifier that differentiates the Card within an Edition. It corresponds to the place in that edition where it was minted.

#### Events for Collection-related actions

- `pub event Withdraw(id: UInt64, from: Address?)`

    Emitted when a Card is withdrawn from a collection. `id` refers to the global Card ID. If the collection was in an account's storage when it was withdrawn, `from` will show the address of the account that it was withdrawn from. If the collection was not in storage when the Card was withdrawn, `from` will be `nil`.

- `pub event Deposit(id: UInt64, to: Address?)`

    Emitted when a Card is deposited into a collection. `id` refers to the global Card ID. If the collection was in an account's storage when it was deposited, `to` will show the address of the account that it was deposited to. If the collection was not in storage when the Card was deposited, `to` will be `nil`.
