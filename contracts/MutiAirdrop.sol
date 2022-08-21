// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultAirdrop is AccessControl {
    event withdrawed(address indexed token);
    event airdropToken(address indexed token, address indexed to, uint256 amount);
    event airdropCoin(address indexed to, uint256 amount);
    event injectCoin(uint amount);

    address[] public tokens;

    bytes32 public constant DAO_ADMIN = keccak256("DAO-ADMIN");
    bytes32 public constant DAO_AGENT = keccak256("DAO-AGENT");

    constructor() {
        _setRoleAdmin(DAO_AGENT,DAO_ADMIN);
        _setRoleAdmin(DAO_ADMIN, DAO_ADMIN);
        _setupRole(DAO_ADMIN, _msgSender());
    }

    function getTokenBalance(address _token) public view returns (uint) {
        return IERC20(_token).balanceOf(msg.sender);
    }

    function containsToken(address _token) public view returns (bool) {
        for (uint256 index = 0; index < tokens.length; index++) {
            if (tokens[index] == _token) {
                return true;
            }
        }
        return false;
    }

    function addToken(address _token) external onlyRole(DAO_ADMIN) {
        require(_token != address(0), "Token address should not be 0");
        require(!containsToken(_token), "Token already added");
        tokens.push(_token);
    }

    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) sum = sum + _arr[i];
    }

    /***********************************|
    |          Coin  Airdrop            |
    |__________________________________*/

    function multiCoinAirdrop(address[] calldata _to, uint[] calldata _amounts)
        external
        onlyRole(DAO_AGENT)
    {
        require(_to.length > 0, "Length of _to must be greater than 0");
        require(_to.length == _amounts.length, "Length of _to and _amounts must be equal");
        for (uint i = 0; i < _to.length; i++) {
            require(_to[i] != address(0), "Address cannot be 0");
            if (_amounts[i] > 0) {
                payable(this).transfer(_amounts[i]);
                emit airdropCoin(_to[i], _amounts[i]);
            }
        }
    }

    function multiCoinAirdropWithSameAmount(
        address[] calldata _to,
        uint _amount
    ) external onlyRole(DAO_AGENT) {
        require(_to.length > 0, "Length of _to must be greater than 0");
        require(_amount > 0, "Amount must be greater than 0");
        for (uint i = 0; i < _to.length; i++) {
            require(_to[i] != address(0), "Address cannot be 0");
            payable(this).transfer(_amount);
            emit airdropCoin(_to[i], _amount);
        }
    }

    /***********************************|
    |          Token  Airdrop           |
    |__________________________________*/

    function multiAllTokenAirdropWithSameAmount(
        address[] calldata _to,
        uint _amount
    ) external onlyRole(DAO_AGENT) {
        for (uint256 index = 0; index < tokens.length; index++) {
            multiTokenAirdropWithSameAmount(_to, tokens[index], _amount);
        }
    }

    function multiTokenAirdropWithSameAmount(
        address[] calldata _to,
        address _token,
        uint _amount
    ) public onlyRole(DAO_AGENT) {
        require(_token != address(0), "Token address cannot be 0");
        require(_to.length > 0, "No addresses to send to");
        require(_amount > 0, "Amount must be greater than 0");
        require(
            getTokenBalance(_token) >= _amount * _to.length,
            "Not enough tokens in the pool"
        );
        for (uint i = 0; i < _to.length; i++) {
            require(_to[i] != address(0), "Address cannot be 0");
            IERC20(_token).transfer(_to[i], _amount);
            emit airdropToken(tokens[i], _to[i], _amount);
        }
    }

    function multiAllTokenAirdrop(
        address[] calldata _to,
        uint[] calldata _amounts
    ) external onlyRole(DAO_AGENT) {
        for (uint256 index = 0; index < tokens.length; index++) {
            multiTokenAirdrop(_to, tokens[index], _amounts);
        }
    }

    function multiTokenAirdrop(
        address[] calldata _to,
        address _token,
        uint[] calldata _amounts
    ) public onlyRole(DAO_AGENT) {
        require(_token != address(0), "Token address cannot be 0");
        require(_to.length > 0, "No addresses to send to");
        require(
            _to.length == _amounts.length,
            "Number of addresses and amounts must be equal"
        );
        require(
            getTokenBalance(_token) >= getSum(_amounts),
            "Not enough tokens in the pool"
        );
        for (uint i = 0; i < _to.length; i++) {
            if (_amounts[i] > 0) {
                require(_to[i] != address(0), "Address cannot be 0");
                IERC20(_token).transfer(_to[i], _amounts[i]);
                emit airdropToken(_token, _to[i], _amounts[i]);
            }
        }
    }

    /***********************************|
    |              Withdraw             |
    |__________________________________*/

    function withdraw() external onlyRole(DAO_ADMIN) {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "fail");
    }

    function withdrawToken(address _token) external onlyRole(DAO_ADMIN) {
        require(_token != address(0), "Token address is not valid");
        IERC20(_token).transfer(
            _msgSender(),
            IERC20(_token).balanceOf(address(this))
        );
        emit withdrawed(_token);
    }

    function withdrawAllToken() external onlyRole(DAO_ADMIN) {
        for (uint i = 0; i < tokens.length; i++) {
            uint balance = IERC20(tokens[i]).balanceOf(address(this));
            if (balance > 0) {
                IERC20(tokens[i]).transfer(_msgSender(), balance);
            }
        }
    }

    /***********************************|
    |               Other               |
    |__________________________________*/

    receive() external payable{
        emit injectCoin(msg.value);
    }

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
}
