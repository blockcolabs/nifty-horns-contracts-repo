package events

import (
	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
)

var (
	EventCardTypeCreated string = "NiftyHorns.CardTypeCreated"
)

type CardTypeCreatedEvent interface {
	Id() uint32
	MetaData() map[interface{}]interface{}
}

type cardTypeCreatedEvent cadence.Event


func (evt cardTypeCreatedEvent) Id() uint32 {
	return evt.Fields[0].(cadence.UInt32).ToGoValue().(uint32)
}
func (evt cardTypeCreatedEvent) MetaData() map[interface{}]interface{} {
	return evt.Fields[1].(cadence.Dictionary).ToGoValue().(map[interface{}]interface{})
}

func DecodeCardTypeCreatedEvent(b []byte) (CardTypeCreatedEvent, error) {
	value, err := jsoncdc.Decode(b)
	if err != nil {
		return nil, err
	}
	return cardTypeCreatedEvent(value.(cadence.Event)), nil
}
