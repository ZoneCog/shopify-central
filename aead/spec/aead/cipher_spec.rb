require 'spec_helper'
require 'aead/cipher'

describe AEAD::Cipher do
  subject { AEAD::Cipher }

  let(:aes_256_gcm)              { subject.new('aes-256-gcm') }
  let(:aes_256_ctr_hmac_sha_256) { subject.new('aes-256-ctr-hmac-sha-256') }

  it 'must instantiate subclasses' do
    subject.new('aes-256-gcm').
      must_equal AEAD::Cipher::AES_256_GCM

    subject.new('aes-256-ctr-hmac-sha-256').
      must_equal AEAD::Cipher::AES_256_CTR_HMAC_SHA_256
  end

  it 'must generate nonces' do
    self.aes_256_ctr_hmac_sha_256.generate_nonce.bytesize.
      must_equal self.aes_256_ctr_hmac_sha_256.nonce_len
  end

  it 'must generate appropriately-sized keys' do
    self.aes_256_gcm.generate_key.bytesize.
      must_equal self.aes_256_gcm.key_len
  end

  it 'must compare signatures' do
    left  = SecureRandom.random_bytes(64)
    right = SecureRandom.random_bytes(64)

    subject.signature_compare(left, right).must_equal false
    subject.signature_compare(left, left) .must_equal true
  end

  bench 'signature_compare on increasingly similar strings' do
    assert_performance_constant 0.99999 do |n|
      left  =                           SecureRandom.random_bytes(10_000)
      right = left.chars.take(n).join + SecureRandom.random_bytes(10_000 - n)

      10.times { subject.signature_compare(left.downcase, right.downcase) }
    end
  end

  bench 'signature_compare on different-sized strings' do
    assert_performance_constant 0.99999 do |n|
      left  = SecureRandom.random_bytes(n)
      right = SecureRandom.random_bytes(n + 1)

      1_000.times { subject.signature_compare(left, right) }
    end
  end

  bench 'signature_compare on increasingly large strings' do
    assert_performance_linear 0.999 do |n|
      string = SecureRandom.random_bytes(n * 500)

      subject.signature_compare(string, string)
    end
  end
end
