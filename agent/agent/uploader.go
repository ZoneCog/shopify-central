package agent

import (
	"github.com/buildkite/agent/api"
)

type Uploader interface {
	// Called before anything happens.
	Setup(string, bool) error

	// The Artifact.URL property is populated with what ever is returned
	// from this method prior to uploading.
	URL(*api.Artifact) string

	// The actual uploading of the file
	Upload(*api.Artifact) error
}
