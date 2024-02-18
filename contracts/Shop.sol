// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Shop {
    // fixed number of item to display
    uint256 constant TOTAL_ITEM = 10;
    // represents the owner of the contract
    address private owner = msg.sender;
    address public buyer;

    // init customer object
    struct Customer {
        uint256 point;
        bool member;
        address productBuyed;
    }

    // init product object
    struct Product {
        string name;
        uint256 cryptoPrice;
        uint256 pointValue;
        uint256 reward;
        address owner;
    }

    Product[TOTAL_ITEM] private products;
    mapping(address => Customer) private customers;

    constructor() public {
        // the buyer will be the msg sender
        buyer = msg.sender;
        // each buyer will have 10 points free
        customers[buyer].point = 0;
        // each buyer have the membership card
        customers[buyer].member = false;

        // assigning default attribute value to 10 products
        for (uint256 index = 0; index < TOTAL_ITEM; index++) {
            products[index].name = "Card";
            // each product will cost 0.1 eth
            products[index].cryptoPrice = 1e17;
            // each product have 3 point value
            products[index].pointValue = 3;
            // each product gives one reward point if it is purchased
            products[index].reward = 1;
            // each product have no owner initially
            products[index].owner = address(0x0);
        }
    }

    // list all products
    function listProductNames() public view returns (string[] memory) {
        // Create a memory array to hold the product names
        string[] memory productNames = new string[](TOTAL_ITEM);

        // Loop through the products and extract names
        for (uint256 i = 0; i < TOTAL_ITEM; i++) {
            productNames[i] = products[i].name; // Store only the name
        }

        // Return the array of product names
        return productNames;
    }

    // Function to retrieve the points of the buyer based on their address.
    function getOwnerPoints() public view returns (uint256 points) {
        points = customers[msg.sender].point;
        return points;
    }

    // Function to retrieve the balance of the buyer based on their address.
    function getOwnerBalance() public view returns (uint256 balance) {
        balance = msg.sender.balance;
        return balance;
    }

    // Checks whether the product exists and has no owner.
    function ValidateProduct(uint256 productId) private view returns (bool) {
        require(productId < TOTAL_ITEM, "This poduct does not exist");
        require(products[productId].owner == address(0x0),"This product has an owner");
        return true;
    }

    // buys a membership card
    function buyMemberCard() external payable {
        require(customers[msg.sender].member == false, "you already have a member card");
        customers[msg.sender].member = true;
        customers[msg.sender].point = 10;
    }

    // buys a product with ETH
    function buyWithCrypto(uint256 productId) external payable {
        // calls the ValidateProduct mehod to check if the product has an owner or doesn't exist
        require(ValidateProduct(productId),"This product doesn't exist or has an owner");
        // checks if the buyer has enough funds to buy
        require(msg.sender.balance >= products[productId].cryptoPrice,"Insufficent crypto funds");
        // changes the owner of the product
        products[productId].owner = msg.sender;
        if (customers[msg.sender].member == true) {
            // adds the reward for buying a product
            customers[msg.sender].point += 1;
        }
    }

    // Buys product with earned points
    function buyWithPoints(uint256 productId) public {
        // calls the ValidateProduct mehod to check if the product has an owner or doesn't exist
        require(customers[msg.sender].member == true , "You don't have a membership card");
        require(ValidateProduct(productId),"This product doesn't exist or has an owner");
        // checks if the buyer has enough points to buy
        require(customers[msg.sender].point >= products[productId].pointValue,"Insufficent points");
        // changes the owner of the product
        products[productId].owner = msg.sender;
        // spends points to buy the product
        customers[msg.sender].point -= products[productId].pointValue;
    }
}
