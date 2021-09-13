package events

import (
	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
)

var (
	EventDropCreated string = "NiftyHorns.DropCreated"
)

type DropCreatedEvent interface {
	DropID() uint32
	Series() uint32
}

type dropCreatedEvent cadence.Event

func (s dropCreatedEvent) DropID() uint32 {
	return uint32(s.Fields[0].(cadence.UInt32))
}

func (s dropCreatedEvent) Series() uint32 {
	return uint32(s.Fields[1].(cadence.UInt32))
}

var _ DropCreatedEvent = (*dropCreatedEvent)(nil)

func DecodeDropCreatedEvent(b []byte) (DropCreatedEvent, error) {
	value, err := jsoncdc.Decode(b)
	if err != nil {
		return nil, err
	}
	return dropCreatedEvent(value.(cadence.Event)), nil
}
