This repo is composed of 5 smart contracts:

1. The Lottery smart contract
   A simple Ethereum-based lottery smart contract built with Solidity. The contract allows any user with an Ethereum wallet to participate by sending 0.1 ETH.
   Each valid transaction registers the sender as a player. The contract is managed by the deployer, who can pick a random winner once at least three players have joined.
   The entire balance is then transferred to the winner, and the lottery resets for the next round.

2. The auction smart contract
   A decentralized auction smart contract on Ethereum, acting as eBay. The contract has an owner, a start and end date, and allows bids through a placeBid() function.
   Users submit ETH, and the contract tracks the highest bidder and the highest binding bid (final price). Bidding follows an automatic increment system up to a user’s maximum.
   The owner can cancel or finalize the auction, and once it ends, the owner receives the highest binding bid while others can withdraw their funds.
   
3. CrowdFunding smart contract
   A decentralized crowdfunding platform built on Ethereum. The admin launches a campaign with a target amount and deadline.
    Contributors fund the campaign by sending ETH. To spend the funds, the admin must create a Spending Request, which requires approval through contributor voting.
   If over 50% approve, funds are released. Power is shifted from the admin to the donors, ensuring transparency.
   If the funding goal isn't met by the deadline, contributors can request a refund.

4. Implementing ERC20 token
   It uses Abstract Contracts and Interfaces. Helps understand the ERC20 token standard and its core requirements. Requires defining state variables, the constructor,
   and all mandatory ERC20 functions and implementation of transfer, approve, and transferFrom for token transactions and allowances.

5. Implementing and Running an ICO (Initial Coin Offering)
   This project features a Solidity-based ICO (Initial Coin Offering) smart contract for a custom ERC20 token named Cryptos (CRPT).
   The contract facilitates the automated sale of tokens in exchange for ETH. CRPT is a fully compliant ERC20 token generated at the time of the ICO.
   Investors send ETH to the ICO contract address and automatically receive CRPT tokens. ETH is forwarded to a specified externally owned account (EOA).
   The ICO will stop accepting ETH after reaching `300 ETH`. Start and end times of the ICO are set by the admin.
