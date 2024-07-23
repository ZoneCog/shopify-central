package hmaclib

import "crypto/hmac"
import "crypto/sha256"
import "encoding/base64"

func DecodeHMAC(message string) []byte {
	decoded, err := base64.StdEncoding.DecodeString(message)
	if err != nil {
		panic(err)
	}
	return decoded
}

func CalculateHMAC(message []byte, key []byte) string {
	mac := hmac.New(sha256.New, []byte(key))
	mac.Write(message)
	expectedMAC := mac.Sum(nil)
	return base64.StdEncoding.EncodeToString(expectedMAC)
}

func CheckHMAC(message []byte, messageMAC string, key []byte) bool {
	extracted_mac := DecodeHMAC(messageMAC)
	calculated_hmac := DecodeHMAC(CalculateHMAC(message, key))
	return hmac.Equal(calculated_hmac, extracted_mac)
}
