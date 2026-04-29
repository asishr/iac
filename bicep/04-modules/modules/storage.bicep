// Storage Account Module — placeholder
// ────────────────────────────────────
// This file is intentionally minimal.
// Let Copilot generate the full module during Exercise 4.
//
// Prompt: "Fill out this Bicep module for an Azure Storage Account.
// Params: workloadName (string), environmentCode (string), location (string), tags (object).
// Derive the storage name as 'st{workloadName}{environmentCode}{locationCode}'.
// Disable public access, enforce HTTPS, TLS 1.2, soft delete blobs 7 days.
// System-assigned identity. Outputs: storageAccountId, storageAccountName, principalId."

@description('Short workload name.')
param workloadName string

@description('Environment shortcode (dev/tst/uat/prd).')
param environmentCode string

@description('Region shortcode used in naming.')
param locationCode string = 'eus'

param location string = resourceGroup().location

@description('Mandatory tags.')
param tags object

// TODO: Let Copilot fill in the rest
