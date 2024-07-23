package hmaclib

import "testing"
import "fmt"
import "bytes"
import "encoding/base64"

var key []byte

func init() {
	key = []byte("adventuretime")
}

func TestDecodingHMAC(t *testing.T) {
	expected_hmac := DecodeHMAC(CalculateHMAC([]byte("hello world"), key))
	decoded_message := DecodeHMAC(base64.StdEncoding.EncodeToString(expected_hmac))
	if bytes.Compare(expected_hmac, decoded_message) != 0 {
		t.Errorf(fmt.Sprintf("expected to decode the message, but got %x instead", decoded_message))
	}
}

func TestCalculatingHMAC(t *testing.T) {
	expected_hmac := DecodeHMAC("mWBFMDhNoDfb9rAXjfaPM1IQMbOjitBk+tS6A6P0kTI=")
	calculated_hmac := DecodeHMAC(CalculateHMAC([]byte("hello world"), key))
	if bytes.Compare(expected_hmac, calculated_hmac) != 0 {
		t.Errorf("expected %v, got %v", expected_hmac, calculated_hmac)
	}
}

func TestCheckHMAC(t *testing.T) {
	message := []byte("hello world")
	message_hmac := CalculateHMAC(message, key)
	if CheckHMAC(message, message_hmac, key) != true {
		t.Errorf("failed hmac comparison. this is weird, right?")
	}
}
