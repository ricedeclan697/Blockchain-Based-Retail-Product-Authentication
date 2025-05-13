# Blockchain-Based Retail Product Authentication

A decentralized system for verifying the authenticity of retail products throughout the supply chain using Clarity smart contracts.

## Overview

This system provides a comprehensive solution for product authentication, enabling:

- Manufacturers to register and verify their products
- Supply chain participants to track product movement
- Retailers to confirm product authenticity
- Consumers to verify products before purchase
- Users to report suspected counterfeit items

## Smart Contracts

The system consists of five interconnected smart contracts:

### 1. Manufacturer Verification Contract

Validates legitimate producers through a registration system managed by a trusted admin.

```clarity
;; Register a new manufacturer
(define-public (register-manufacturer (manufacturer-principal principal) (name (string-utf8 100)))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-none (map-get? manufacturers manufacturer-principal)) (err ERR_ALREADY_REGISTERED))
    
    (map-set manufacturers 
      manufacturer-principal
      {
        name: name,
        verified: true,
        registration-date: block-height
      }
    )
    (ok true)
  )
)
