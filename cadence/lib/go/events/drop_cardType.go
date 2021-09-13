package events

import (
	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
)

var (
	EventCardTypeAddedToDrop string = "NiftyHorns.CardTypeAddedToDrop"
)

type CardTypeAddedToDropEvent interface {
	DropID() uint32
	CardTypeID() uint32
}

type cardTypeAddedToDropEvent cadence.Event

func (p cardTypeAddedToDropEvent) DropID() uint32 {
	return uint32(p.Fields[0].(cadence.UInt32))
}

func (p cardTypeAddedToDropEvent) CardTypeID() uint32 {
	return uint32(p.Fields[1].(cadence.UInt32))
}

var _ CardTypeAddedToDropEvent = (*cardTypeAddedToDropEvent)(nil)

func DecodeCardTypeAddedToDropEvent(b []byte)(CardTypeAddedToDropEvent, error) {
	value, err := jsoncdc.Decode(b)
	if err != nil {
		return nil, err
	}
	return cardTypeAddedToDropEvent(value.(cadence.Event)), nil

}
