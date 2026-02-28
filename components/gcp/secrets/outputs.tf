output "kms_key_ring_id" {
  description = "The ID of the Cloud KMS key ring"
  value       = google_kms_key_ring.secrets.id
}

output "kms_key_id" {
  description = "The ID of the Cloud KMS crypto key"
  value       = google_kms_crypto_key.secrets.id
}
