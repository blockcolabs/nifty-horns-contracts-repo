package events

import (
	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
)

var (
	// This variable specifies that there is a CardMinted Event on a NiftyHorns Contract located at address 0x04
	EventCardMinted = "NiftyHorns.CardMinted"
)

type CardMintedEvent interface {
	CardId() uint64
	CardTypeId() uint32
	DropId() uint32
	SerialNumber() uint32
}

type cardMintedEvent cadence.Event

func (a cardMintedEvent) CardId() uint64 {
	return uint64(a.Fields[0].(cadence.UInt64))
}

func (a cardMintedEvent) CardTypeId() uint32 {
	return uint32(a.Fields[1].(cadence.UInt32))
}

func (a cardMintedEvent) DropId() uint32 {
	return uint32(a.Fields[2].(cadence.UInt32))
}

func (a cardMintedEvent) SerialNumber() uint32 {
	return uint32(a.Fields[3].(cadence.UInt32))
}

var _ CardMintedEvent = (*cardMintedEvent)(nil)

func DecodeCardMintedEvent(b []byte) (CardMintedEvent, error) {
	value, err := jsoncdc.Decode(b)
	if err != nil {
		return nil, err
	}
	return cardMintedEvent(value.(cadence.Event)), nil
}
