// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ngl {
    address public owner;
    IERC20 public usdtToken;
    uint256 public messageFee = 1e4; // 0.01 USDT with 6 decimals (USDT uses 6 decimals)

    struct Message {
        string content;
        uint256 timestamp;
    }

    Message[] public messages;

    event NewMessage(uint256 indexed messageId, string content, uint256 timestamp);

    constructor(address _usdtToken) {
        owner = msg.sender;
        usdtToken = IERC20(_usdtToken);
    }

    function sendMessage(string memory _content) external {
        require(bytes(_content).length > 0, "Message cannot be empty");

        // Transfer 0.01 USDT from sender to the contract
        require(usdtToken.transferFrom(msg.sender, address(this), messageFee), "USDT payment failed");

        messages.push(Message({
            content: _content,
            timestamp: block.timestamp
        }));

        emit NewMessage(messages.length - 1, _content, block.timestamp);
    }

    function getMessages() external view returns (Message[] memory) {
        return messages;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not authorized");
        uint256 balance = usdtTokenBalance();
        require(usdtToken.transfer(owner, balance), "Withdraw failed");
    }

    function usdtTokenBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }
}
