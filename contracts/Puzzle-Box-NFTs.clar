;; Puzzle Box NFT Contract
;; NFTs that unlock only after solving on-chain riddles

;; Define NFT
(define-non-fungible-token puzzle-box-nft uint)

;; Storage maps
(define-map nft-metadata uint {
  name: (string-ascii 64),
  description: (string-ascii 256),
  image-uri: (string-ascii 256),
  is-unlocked: bool
})

(define-map puzzle-data uint {
  question: (string-ascii 512),
  answer-hash: (buff 32),
  hint: (string-ascii 256)
})

;; Contract variables
(define-data-var next-token-id uint u1)
(define-data-var contract-owner principal tx-sender)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-UNLOCKED (err u102))
(define-constant ERR-WRONG-ANSWER (err u103))
(define-constant ERR-ALREADY-EXISTS (err u104))

;; Read-only functions
(define-read-only (get-owner)
  (var-get contract-owner)
)

(define-read-only (get-last-token-id)
  (- (var-get next-token-id) u1)
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (get image-uri (unwrap! (map-get? nft-metadata token-id) (err u101)))))
)

(define-read-only (get-nft-metadata (token-id uint))
  (map-get? nft-metadata token-id)
)

(define-read-only (get-puzzle-question (token-id uint))
  (match (map-get? puzzle-data token-id)
    puzzle-info (ok (get question puzzle-info))
    (err u101)
  )
)

(define-read-only (get-puzzle-hint (token-id uint))
  (match (map-get? puzzle-data token-id)
    puzzle-info (ok (get hint puzzle-info))
    (err u101)
  )
)

(define-read-only (is-unlocked (token-id uint))
  (match (map-get? nft-metadata token-id)
    metadata (ok (get is-unlocked metadata))
    (err u101)
  )
)

;; Mint new puzzle box NFT
(define-public (mint-puzzle-nft 
  (recipient principal)
  (name (string-ascii 64))
  (description (string-ascii 256))
  (image-uri (string-ascii 256))
  (question (string-ascii 512))
  (answer (string-ascii 256))
  (hint (string-ascii 256)))

  (let ((token-id (var-get next-token-id))
        (answer-hash (sha256 (unwrap! (to-consensus-buff? answer) (err u999)))))

    ;; Only contract owner can mint
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)

    ;; Mint the NFT
    (try! (nft-mint? puzzle-box-nft token-id recipient))

    ;; Store metadata (initially locked)
    (map-set nft-metadata token-id {
      name: name,
      description: description,
      image-uri: image-uri,
      is-unlocked: false
    })

    ;; Store puzzle data
    (map-set puzzle-data token-id {
      question: question,
      answer-hash: answer-hash,
      hint: hint
    })

    ;; Increment token ID for next mint
    (var-set next-token-id (+ token-id u1))

    (ok token-id)
  )
)

;; Solve puzzle to unlock NFT
(define-public (solve-puzzle (token-id uint) (answer (string-ascii 256)))
  (let ((nft-owner (unwrap! (nft-get-owner? puzzle-box-nft token-id) ERR-NOT-FOUND))
        (metadata (unwrap! (map-get? nft-metadata token-id) ERR-NOT-FOUND))
        (puzzle-info (unwrap! (map-get? puzzle-data token-id) ERR-NOT-FOUND))
        (answer-hash (sha256 (unwrap! (to-consensus-buff? answer) (err u999)))))

    ;; Only NFT owner can solve puzzle
    (asserts! (is-eq tx-sender nft-owner) ERR-NOT-AUTHORIZED)

    ;; Check if already unlocked
    (asserts! (not (get is-unlocked metadata)) ERR-ALREADY-UNLOCKED)

    ;; Verify answer
    (asserts! (is-eq answer-hash (get answer-hash puzzle-info)) ERR-WRONG-ANSWER)

    ;; Update metadata to unlocked
    (map-set nft-metadata token-id (merge metadata { is-unlocked: true }))

    (ok true)
  )
)

;; Transfer function (only works for unlocked NFTs)
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((metadata (unwrap! (map-get? nft-metadata token-id) ERR-NOT-FOUND)))

    ;; Check authorization
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR-NOT-AUTHORIZED)

    ;; Only allow transfer of unlocked NFTs
    (asserts! (get is-unlocked metadata) ERR-NOT-AUTHORIZED)

    ;; Execute transfer
    (nft-transfer? puzzle-box-nft token-id sender recipient)
  )
)

;; Get all puzzle info for debugging (owner only)
(define-read-only (get-puzzle-debug-info (token-id uint))
  (if (is-eq tx-sender (var-get contract-owner))
    (map-get? puzzle-data token-id)
    none
  )
)