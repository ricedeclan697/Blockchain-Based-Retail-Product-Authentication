;; Manufacturer Verification Contract
;; This contract validates legitimate producers

(define-data-var admin principal tx-sender)

;; Map to store verified manufacturers
(define-map manufacturers
  principal
  {
    name: (string-utf8 100),
    verified: bool,
    registration-date: uint
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_ALREADY_REGISTERED u101)
(define-constant ERR_NOT_FOUND u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

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

;; Revoke manufacturer verification
(define-public (revoke-manufacturer (manufacturer-principal principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some (map-get? manufacturers manufacturer-principal)) (err ERR_NOT_FOUND))

    (map-set manufacturers
      manufacturer-principal
      (merge (unwrap-panic (map-get? manufacturers manufacturer-principal))
             { verified: false })
    )
    (ok true)
  )
)

;; Check if a manufacturer is verified
(define-read-only (is-verified-manufacturer (manufacturer-principal principal))
  (match (map-get? manufacturers manufacturer-principal)
    manufacturer (ok (get verified manufacturer))
    (err ERR_NOT_FOUND)
  )
)

;; Get manufacturer details
(define-read-only (get-manufacturer-details (manufacturer-principal principal))
  (map-get? manufacturers manufacturer-principal)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)
