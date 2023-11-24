// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../contracts/ERC6551/ERC6551Registry.sol";
import "../../contracts/ERC6551/ERC6551Account.sol";
import "../../contracts/ERC6551/AccountProxy.sol";
import "../../contracts/SpaceshipUniverse1.sol";
import "../../contracts/SpaceFactoryV1.sol";
import "../../contracts/BadgeUniverse1.sol";
import "../mocks/MockERC721.sol";
import "../../contracts/interfaces/IERC6551Account.sol";

contract DefaultSetup is Test {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    address defaultAdmin;
    address serviceAdmin;
    uint256 serviceAdminPk;
    address minterAdmin;
    ERC6551Registry public registry;
    ERC6551Account public erc6551Account;
    IERC6551Account public implementation;
    SpaceFactoryV1 public factory;
    SpaceFactoryV1 public factoryImplemenation;
    SpaceshipUniverse1 public spaceship;
    BadgeUniverse1 public badge;
    MockERC721 public externalERC721;
    uint16 maxSupply = 10;
    address[] users;

    function setUp() public virtual {
        defaultAdmin = vm.addr(1);
        serviceAdmin = vm.addr(2);
        serviceAdminPk = 2;
        minterAdmin = vm.addr(3);
        externalERC721 = new MockERC721();

        registry = new ERC6551Registry();
        erc6551Account = new ERC6551Account();
        // implementation is also a proxy to ERC6551Account
        implementation = IERC6551Account(
            payable(address(new AccountProxy(address(erc6551Account))))
        );
        factoryImplemenation = new SpaceFactoryV1();
        factory = SpaceFactoryV1(
            address(
                new ERC1967Proxy(
                    address(factoryImplemenation),
                    abi.encodeWithSignature(
                        "initialize(address,address,address,address,address,bool,(uint128,uint128))",
                        defaultAdmin,
                        serviceAdmin,
                        minterAdmin,
                        registry,
                        implementation,
                        false,
                        IBadgeUniverse1.TokenType(0, 0)
                    )
                )
            )
        );
        spaceship = new SpaceshipUniverse1(
            address(factory),
            maxSupply,
            defaultAdmin,
            defaultAdmin
        );
        badge = new BadgeUniverse1(address(factory), defaultAdmin);
        vm.startPrank(defaultAdmin);
        factory.setSpaceshipUniverse1(address(spaceship));
        factory.setBadgeUniverse1(address(badge));
        vm.stopPrank();

        for (uint256 i = 0; i < maxSupply + 1; i++) {
            users.push(vm.addr(i + 4));
        }
    }

    function getTBAaddress(
        address nftContractAddress,
        uint256 tokenId
    ) internal view returns (address) {
        return
            registry.account(
                address(implementation),
                block.chainid,
                address(nftContractAddress),
                tokenId,
                0 // salt
            );
    }

    function deployTBA(
        address nftContractAddress,
        uint256 tokenId
    ) internal returns (address) {
        return
            registry.createAccount(
                address(implementation),
                block.chainid,
                address(nftContractAddress),
                tokenId,
                0, // salt
                abi.encodeWithSignature("initialize()")
            );
    }
}
