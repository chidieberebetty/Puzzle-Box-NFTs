📦 Puzzle Box NFT Contract

Overview

The Puzzle Box NFT Contract is a Clarity smart contract that introduces a new type of interactive NFT. Each NFT represents a digital "puzzle box" that remains locked until the owner solves an on-chain riddle. Once solved, the NFT becomes unlocked and can be freely transferred.

This gamified mechanism adds utility and engagement to NFTs, making them more than just static collectibles.

✨ Features

Non-Fungible Token Standard: Implements NFTs using define-non-fungible-token.

On-Chain Puzzles: Each NFT is minted with a riddle, hashed answer, and optional hint.

Unlock Mechanism: NFT owners must provide the correct solution to unlock their token.

Transfer Restrictions: NFTs can only be transferred once unlocked, ensuring puzzles are solved by the rightful owner.

Owner Controls: Only the contract owner can mint new puzzle NFTs.

Debugging Access: Contract owner can view puzzle data for verification/testing.

📖 Functions
Read-Only

get-owner → Returns contract owner.

get-last-token-id → Returns the most recent token ID.

get-token-uri (token-id) → Returns the NFT’s image URI.

get-nft-metadata (token-id) → Fetches full NFT metadata.

get-puzzle-question (token-id) → Returns the riddle/question for the puzzle.

get-puzzle-hint (token-id) → Returns the associated hint.

is-unlocked (token-id) → Checks if an NFT has been unlocked.

get-puzzle-debug-info (token-id) → Returns puzzle data (contract owner only).

Public

mint-puzzle-nft (recipient name description image-uri question answer hint)
Mints a new puzzle NFT with locked metadata and associated riddle.

solve-puzzle (token-id answer)
Allows the NFT owner to attempt solving the puzzle. If correct, unlocks the NFT.

transfer (token-id sender recipient)
Transfers an unlocked NFT from one owner to another.

🔐 Access Control

Minting: Restricted to contract owner.

Solving: Restricted to NFT owner.

Transferring: Only allowed if NFT is unlocked.

⚠️ Errors

ERR-NOT-AUTHORIZED (u100) → Caller not permitted.

ERR-NOT-FOUND (u101) → Token not found.

ERR-ALREADY-UNLOCKED (u102) → NFT already unlocked.

ERR-WRONG-ANSWER (u103) → Puzzle answer incorrect.

ERR-ALREADY-EXISTS (u104) → NFT already exists.

🚀 Example Flow

Mint NFT – Owner creates a new puzzle NFT with a riddle.

Check Puzzle – User retrieves the puzzle question and hint.

Solve Puzzle – Owner submits answer; if correct, NFT is unlocked.

Transfer NFT – Once unlocked, NFT can be traded or transferred.

✅ Use Cases

Gamified Collectibles: Reward solving riddles with transferable NFTs.

Educational Quests: Teach concepts by embedding puzzles in NFTs.

Exclusive Access: Unlock NFTs to gain entry to private content/events.

On-Chain Treasure Hunts: Distribute riddles across NFTs for a larger game.

📄 License

MIT License. Free to use and modify.