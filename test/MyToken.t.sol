// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

/// @title MyTokenTest
/// @notice Tests for the ERC-20 token
contract MyTokenTest is Test {
    MyToken public token;

    address public owner;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 public constant INITIAL_SUPPLY = 1000 * 10 ** 18;

    function setUp() public {
        owner = address(this);
        token = new MyToken();
    }

    // ==========================================================================
    // DEPLOYMENT TESTS
    // ==========================================================================

    function test_Name() public view {
        assertEq(token.name(), "MyToken");
    }

    function test_Symbol() public view {
        assertEq(token.symbol(), "MTK");
    }

    function test_Decimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_OwnerHasInitialSupply() public view {
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    // ==========================================================================
    // TRANSFER TESTS
    // ==========================================================================

    function test_Transfer() public {
        uint256 amount = 100 * 10 ** 18;

        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferFrom() public {
        uint256 amount = 50 * 10 ** 18;

        // Owner approves Alice to spend tokens
        token.approve(alice, amount);

        // Alice transfers tokens from owner to Bob
        vm.prank(alice);
        token.transferFrom(owner, bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function test_TransferFailsWithInsufficientBalance() public {
        uint256 tooMuch = INITIAL_SUPPLY + 1;

        vm.expectRevert();
        token.transfer(alice, tooMuch);
    }

    // ==========================================================================
    // MINT TESTS
    // ==========================================================================

    function test_OwnerCanMint() public {
        uint256 mintAmount = 500 * 10 ** 18;

        token.mint(alice, mintAmount);

        assertEq(token.balanceOf(alice), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }

    function test_NonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 100 * 10 ** 18);
    }

    // ==========================================================================
    // BURN TESTS
    // ==========================================================================

    function test_CanBurnOwnTokens() public {
        uint256 burnAmount = 100 * 10 ** 18;

        token.burn(burnAmount);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }

    function test_CannotBurnMoreThanBalance() public {
        // Give Alice some tokens
        token.transfer(alice, 10 * 10 ** 18);

        // Alice tries to burn more than she has
        vm.prank(alice);
        vm.expectRevert();
        token.burn(100 * 10 ** 18);
    }

    // ==========================================================================
    // FUZZ TESTS
    // ==========================================================================

    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount <= INITIAL_SUPPLY);

        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
    }

    function testFuzz_Mint(uint256 amount) public {
        vm.assume(amount < type(uint256).max - INITIAL_SUPPLY);

        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }
}
