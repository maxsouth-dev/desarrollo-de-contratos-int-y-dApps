// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AcademicCredentials} from "../src/AcademicCredentials.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AcademicCredentialsTest is Test {
    AcademicCredentials public creds;

    address public admin = address(this);
    address public alice = makeAddr("alice");
    address public bob   = makeAddr("bob");
    address public carol = makeAddr("carol");

    bytes32 public constant ISSUER_ROLE        = keccak256("ISSUER_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE  = 0x00;

    // sample credential fields
    string  constant DEGREE      = "Licenciatura en Sistemas";
    bytes32 constant NAME_HASH   = keccak256("Juan Perez");
    bytes32 constant DOC_HASH    = keccak256("diploma-pdf-bytes");
    string  constant METADATA    = "ipfs://bafy.../credential-1.json";

    function setUp() public {
        creds = new AcademicCredentials();
    }

    // ==========================================================================
    // DEPLOYMENT
    // ==========================================================================

    function test_NameAndSymbol() public view {
        assertEq(creds.name(),   "UNQ Academic Credential");
        assertEq(creds.symbol(), "UNQ-CRED");
    }

    function test_DeployerHasAdminRole() public view {
        assertTrue(creds.hasRole(DEFAULT_ADMIN_ROLE, admin));
    }

    function test_DeployerHasIssuerRole() public view {
        assertTrue(creds.hasRole(ISSUER_ROLE, admin));
    }

    // ==========================================================================
    // ROLE MANAGEMENT
    // ==========================================================================

    function test_AdminCanGrantIssuer() public {
        creds.grantIssuer(carol);
        assertTrue(creds.hasRole(ISSUER_ROLE, carol));
    }

    function test_GrantIssuerEmitsEvent() public {
        vm.expectEmit(true, true, false, false);
        emit AcademicCredentials.IssuerGranted(carol, admin);
        creds.grantIssuer(carol);
    }

    function test_AdminCanRevokeIssuer() public {
        creds.grantIssuer(carol);
        creds.revokeIssuer(carol);
        assertFalse(creds.hasRole(ISSUER_ROLE, carol));
    }

    function test_RevokeIssuerEmitsEvent() public {
        creds.grantIssuer(carol);
        vm.expectEmit(true, true, false, false);
        emit AcademicCredentials.IssuerRevoked(carol, admin);
        creds.revokeIssuer(carol);
    }

    function test_NonAdminCannotGrantIssuer() public {
        vm.prank(alice);
        vm.expectRevert();
        creds.grantIssuer(bob);
    }

    function test_GrantedIssuerCanIssue() public {
        creds.grantIssuer(carol);
        vm.prank(carol);
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        assertEq(creds.ownerOf(1), alice);
    }

    function test_RevokedIssuerCannotIssue() public {
        creds.grantIssuer(carol);
        creds.revokeIssuer(carol);
        vm.prank(carol);
        vm.expectRevert();
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    // ==========================================================================
    // ISSUE — happy path
    // ==========================================================================

    function test_IssueStoresAllFields() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);

        (AcademicCredentials.Credential memory c, bool valid) = creds.verify(1);

        assertEq(c.degreeName,      DEGREE);
        assertEq(c.studentNameHash, NAME_HASH);
        assertEq(c.documentHash,    DOC_HASH);
        assertTrue(c.active);
        assertTrue(valid);
        assertEq(creds.ownerOf(1),  alice);
        assertEq(creds.tokenURI(1), METADATA);
    }

    function test_IssuingEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit AcademicCredentials.CredentialIssued(alice, 42, DEGREE, NAME_HASH);
        creds.issueCredential(alice, 42, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    function test_IssueDateIsSet() public {
        vm.warp(1_700_000_000);
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        (AcademicCredentials.Credential memory c,) = creds.verify(1);
        assertEq(c.issueDate, 1_700_000_000);
    }

    // ==========================================================================
    // ISSUE — error cases
    // ==========================================================================

    function test_NonIssuerCannotIssue() public {
        vm.prank(alice);
        vm.expectRevert();
        creds.issueCredential(bob, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    function test_CannotIssueToZeroAddress() public {
        vm.expectRevert("AcademicCredentials: zero address");
        creds.issueCredential(address(0), 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    function test_CannotIssueEmptyDegreeName() public {
        vm.expectRevert("AcademicCredentials: empty degreeName");
        creds.issueCredential(alice, 1, "", NAME_HASH, DOC_HASH, METADATA);
    }

    function test_CannotIssueEmptyStudentNameHash() public {
        vm.expectRevert("AcademicCredentials: empty studentNameHash");
        creds.issueCredential(alice, 1, DEGREE, bytes32(0), DOC_HASH, METADATA);
    }

    function test_CannotIssueEmptyDocumentHash() public {
        vm.expectRevert("AcademicCredentials: empty documentHash");
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, bytes32(0), METADATA);
    }

    function test_CannotIssueDuplicateTokenId() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.expectRevert();
        creds.issueCredential(bob, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    // ==========================================================================
    // REVOKE
    // ==========================================================================

    function test_IssuerCanRevoke() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        creds.revoke(1, "Error en datos");

        (, bool valid) = creds.verify(1);
        assertFalse(valid);
    }

    function test_RevokingEmitsEvent() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.expectEmit(true, true, false, true);
        emit AcademicCredentials.CredentialRevoked(1, admin, "Error en datos");
        creds.revoke(1, "Error en datos");
    }

    function test_NonIssuerCannotRevoke() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.prank(alice);
        vm.expectRevert();
        creds.revoke(1, "intento malicioso");
    }

    function test_CannotRevokeNonExistent() public {
        vm.expectRevert();
        creds.revoke(999, "no existe");
    }

    function test_CannotRevokeAlreadyRevoked() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        creds.revoke(1, "primera vez");
        vm.expectRevert();
        creds.revoke(1, "segunda vez");
    }

    // ==========================================================================
    // VERIFY
    // ==========================================================================

    function test_VerifyReturnsFalseForNonExistent() public view {
        (, bool valid) = creds.verify(999);
        assertFalse(valid);
    }

    function test_VerifyReturnsTrueForActive() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        (, bool valid) = creds.verify(1);
        assertTrue(valid);
    }

    function test_VerifyReturnsFalseAfterRevoke() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        creds.revoke(1, "revocado");
        (, bool valid) = creds.verify(1);
        assertFalse(valid);
    }

    // ==========================================================================
    // SOULBOUND
    // ==========================================================================

    function test_CannotTransferCredential() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.prank(alice);
        vm.expectRevert("AcademicCredentials: non-transferable");
        creds.transferFrom(alice, bob, 1);
    }

    function test_CannotSafeTransferCredential() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.prank(alice);
        vm.expectRevert("AcademicCredentials: non-transferable");
        creds.safeTransferFrom(alice, bob, 1);
    }

    function test_OwnerUnchangedAfterTransferAttempt() public {
        creds.issueCredential(alice, 1, DEGREE, NAME_HASH, DOC_HASH, METADATA);
        vm.prank(alice);
        vm.expectRevert("AcademicCredentials: non-transferable");
        creds.transferFrom(alice, bob, 1);
        assertEq(creds.ownerOf(1), alice);
    }

    // ==========================================================================
    // FUZZ
    // ==========================================================================

    function testFuzz_IssueToAnyAddress(address student, uint256 tokenId) public {
        vm.assume(student != address(0));

        creds.issueCredential(student, tokenId, DEGREE, NAME_HASH, DOC_HASH, METADATA);

        assertEq(creds.ownerOf(tokenId), student);
        (, bool valid) = creds.verify(tokenId);
        assertTrue(valid);
    }

    function testFuzz_CannotIssueToZeroAddress(uint256 tokenId) public {
        vm.expectRevert("AcademicCredentials: zero address");
        creds.issueCredential(address(0), tokenId, DEGREE, NAME_HASH, DOC_HASH, METADATA);
    }

    function test_SupportsERC721Interface() public view {
        assertTrue(creds.supportsInterface(type(IERC721).interfaceId));
    }

    function testFuzz_TransferAlwaysReverts(address student, address recipient, uint256 tokenId) public {
        vm.assume(student    != address(0));
        vm.assume(recipient  != address(0));

        creds.issueCredential(student, tokenId, DEGREE, NAME_HASH, DOC_HASH, METADATA);

        vm.prank(student);
        vm.expectRevert("AcademicCredentials: non-transferable");
        creds.transferFrom(student, recipient, tokenId);
    }
}
