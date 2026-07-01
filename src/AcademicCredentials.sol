// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title AcademicCredentials
/// @notice ERC-721 soulbound credential registry for UNQ academic titles.
/// @dev Tokens are non-transferable (soulbound). Role-based access:
///      DEFAULT_ADMIN_ROLE (rector) manages issuers.
///      ISSUER_ROLE (deans/secretaries) issues and revokes credentials.
contract AcademicCredentials is ERC721URIStorage, AccessControl {

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    // ==========================================================================
    // STRUCTS
    // ==========================================================================

    struct Credential {
        string   degreeName;
        bytes32  studentNameHash;  // keccak256 of student name (privacy)
        uint256  issueDate;        // block.timestamp at issuance
        bytes32  documentHash;     // keccak256 of original PDF
        bool     active;           // false if revoked
    }

    mapping(uint256 => Credential) public credentials;

    // ==========================================================================
    // EVENTS
    // ==========================================================================

    event CredentialIssued(
        address indexed student,
        uint256 indexed tokenId,
        string  degreeName,
        bytes32 studentNameHash
    );

    event CredentialRevoked(
        uint256 indexed tokenId,
        address indexed by,
        string  reason
    );

    event IssuerGranted(
        address indexed account,
        address indexed by
    );

    event IssuerRevoked(
        address indexed account,
        address indexed by
    );

    // ==========================================================================
    // CONSTRUCTOR
    // ==========================================================================

    /// @notice Deployer gets DEFAULT_ADMIN_ROLE and ISSUER_ROLE.
    constructor() ERC721("UNQ Academic Credential", "UNQ-CRED") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ISSUER_ROLE, msg.sender);
    }

    // ==========================================================================
    // ADMIN — role management
    // ==========================================================================

    /// @notice Grants ISSUER_ROLE to an account.
    /// @param account address to grant the role to
    function grantIssuer(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ISSUER_ROLE, account);
        emit IssuerGranted(account, msg.sender);
    }

    /// @notice Revokes ISSUER_ROLE from an account.
    /// @param account address to revoke the role from
    function revokeIssuer(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(ISSUER_ROLE, account);
        emit IssuerRevoked(account, msg.sender);
    }

    // ==========================================================================
    // ISSUER — credential lifecycle
    // ==========================================================================

    /// @notice Issues a new credential to a student wallet.
    /// @param student          recipient wallet
    /// @param tokenId          unique id for this credential
    /// @param degreeName       name of the degree (e.g. "Licenciatura en Sistemas")
    /// @param studentNameHash  keccak256 of the student's full name
    /// @param documentHash     keccak256 of the original PDF diploma
    /// @param metadataURI      ipfs:// URI pointing to the credential JSON
    function issueCredential(
        address student,
        uint256 tokenId,
        string  memory degreeName,
        bytes32 studentNameHash,
        bytes32 documentHash,
        string  memory metadataURI
    ) external onlyRole(ISSUER_ROLE) {
        require(student != address(0),        "AcademicCredentials: zero address");
        require(bytes(degreeName).length > 0, "AcademicCredentials: empty degreeName");
        require(studentNameHash != bytes32(0),"AcademicCredentials: empty studentNameHash");
        require(documentHash    != bytes32(0),"AcademicCredentials: empty documentHash");

        _mint(student, tokenId);
        _setTokenURI(tokenId, metadataURI);

        credentials[tokenId] = Credential({
            degreeName:      degreeName,
            studentNameHash: studentNameHash,
            issueDate:       block.timestamp,
            documentHash:    documentHash,
            active:          true
        });

        emit CredentialIssued(student, tokenId, degreeName, studentNameHash);
    }

    /// @notice Revokes a previously issued credential.
    /// @param tokenId  credential id to revoke
    /// @param reason   human-readable reason for revocation
    function revoke(uint256 tokenId, string memory reason) external onlyRole(ISSUER_ROLE) {
        require(credentials[tokenId].active, "AcademicCredentials: not active");
        credentials[tokenId].active = false;
        _burn(tokenId);
        emit CredentialRevoked(tokenId, msg.sender, reason);
    }

    // ==========================================================================
    // PUBLIC — verification (anyone)
    // ==========================================================================

    /// @notice Returns the stored credential data and its current validity.
    /// @param tokenId  credential id to verify
    /// @return cred    the Credential struct
    /// @return isValid true if credential exists and has not been revoked
    function verify(uint256 tokenId) external view returns (Credential memory cred, bool isValid) {
        cred    = credentials[tokenId];
        isValid = _ownerOf(tokenId) != address(0) && cred.active;
    }

    // ==========================================================================
    // SOULBOUND — block all transfers
    // ==========================================================================

    /// @dev Reverts on any transfer. Mints (from == 0) and burns (to == 0) are allowed.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("AcademicCredentials: non-transferable");
        }
        return super._update(to, tokenId, auth);
    }

    // ==========================================================================
    // INTERFACE SUPPORT
    // ==========================================================================

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
