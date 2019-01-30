## doc: https://www.terraform.io/docs/backends/types/gcs.html
terraform {
    backend "gcs" {
            bucket = "storage-bucket-rain"
            prefix = "stage"
    }
}
