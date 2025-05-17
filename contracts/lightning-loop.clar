;; Title: Lightning Loop - Bitcoin-native Payment Channel Protocol for Stacks
;;
;; Summary: A secure, efficient payment channel implementation enabling off-chain 
;; transactions with on-chain settlement for Stacks blockchain, fully compatible
;; with Bitcoin's security model.
;;
;; Description: Lightning Loop enables near-instant, high-throughput microtransactions
;; by establishing two-party payment channels where participants can exchange value
;; multiple times off-chain, only settling to the blockchain when necessary. This
;; implementation provides complete lifecycle management of payment channels
;; including creation, funding, cooperative/unilateral closing, and dispute resolution.
;;

;; Constants

(define-constant CONTRACT-OWNER tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CHANNEL-EXISTS (err u101))
(define-constant ERR-CHANNEL-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-INVALID-SIGNATURE (err u104))
(define-constant ERR-CHANNEL-CLOSED (err u105))
(define-constant ERR-DISPUTE-PERIOD (err u106))
(define-constant ERR-INVALID-INPUT (err u107))

;; Data Models

;; Storage for payment channels
(define-map payment-channels
  {
    channel-id: (buff 32), ;; Unique identifier for the channel
    participant-a: principal, ;; First participant
    participant-b: principal, ;; Second participant
  }
  {
    total-deposited: uint, ;; Total funds deposited in the channel
    balance-a: uint, ;; Balance for participant A
    balance-b: uint, ;; Balance for participant B
    is-open: bool, ;; Channel open/closed status
    dispute-deadline: uint, ;; Timestamp for dispute resolution
    nonce: uint, ;; Prevents replay attacks
  }
)

;; Helper Functions

;; Validates channel ID format
(define-private (is-valid-channel-id (channel-id (buff 32)))
  (and
    (> (len channel-id) u0)
    (<= (len channel-id) u32)
  )
)

;; Ensures deposit amount is valid
(define-private (is-valid-deposit (amount uint))
  (> amount u0)
)