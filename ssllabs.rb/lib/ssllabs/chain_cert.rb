module Ssllabs
  class ChainCert < ApiObject
    has_fields :subject,
      :label,
      :notBefore,
      :notAfter,
      :issuerSubject,
      :issuerLabel,
      :sigAlg,
      :issues,
      :keyAlg,
      :sha1Hash,
      :pinSha256,
      :keySize,
      :keyStrength,
      :revocationStatus,
      :crlRevocationStatus,
      :ocspRevocationStatus,
      :raw

    def valid?
      issues == 0
    end

    def invalid?
      !valid?
    end
  end
end
