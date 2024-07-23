package agent

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestS3DowloaderBucketPath(t *testing.T) {
	s3Uploader := S3Downloader{Bucket: "s3://my-bucket-name/foo/bar"}
	assert.Equal(t, s3Uploader.BucketPath(), "foo/bar")

	s3Uploader.Bucket = "s3://starts-with-an-s/and-this-is-its/folder"
	assert.Equal(t, s3Uploader.BucketPath(), "and-this-is-its/folder")
}

func TestS3DowloaderBucketName(t *testing.T) {
	s3Uploader := S3Downloader{Bucket: "s3://my-bucket-name/foo/bar"}
	assert.Equal(t, s3Uploader.BucketName(), "my-bucket-name")

	s3Uploader.Bucket = "s3://starts-with-an-s"
	assert.Equal(t, s3Uploader.BucketName(), "starts-with-an-s")
}

func TestS3DowloaderBucketFileLocation(t *testing.T) {
	s3Uploader := S3Downloader{Bucket: "s3://my-bucket-name/s3/folder", Path: "here/please/right/now/"}
	assert.Equal(t, s3Uploader.BucketFileLocation(), "s3/folder/here/please/right/now/")

	s3Uploader.Path = ""
	assert.Equal(t, s3Uploader.BucketFileLocation(), "s3/folder/")
}
