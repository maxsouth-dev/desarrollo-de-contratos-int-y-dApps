// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title MyToken
/// @notice Simple ERC-20 token for the course
/// @dev Inherits from OpenZeppelin ERC20 and Ownable
contract MyToken is ERC20, Ownable {
    // ==========================================================================
    // CONSTRUCTOR
    // ==========================================================================

    /// @notice Creates the token and mints initial supply to deployer
    /// @dev The deployer becomes owner automatically
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        // Mint 1000 tokens to deployer
        // decimals() is 18 by default, so:
        // 1000 tokens = 1000 * 10^18 = 1000 * 10**decimals()
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    // ==========================================================================
    // ADDITIONAL FUNCTIONS
    // ==========================================================================

    /// @notice Allows owner to mint more tokens
    /// @param to Address that receives the tokens
    /// @param amount Amount to mint (in wei, not tokens)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice Allows anyone to burn their own tokens
    /// @param amount Amount to burn
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
