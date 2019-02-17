pragma solidity ^0.5.0;

contract Raffle{

    address owner;
    mapping(address => uint) balances;
    mapping(address => bytes32) guesses;

    bytes32 public secretHash;

        
    constructor() public {
        owner = msg.sender;
    }
    
    function setHash(bytes32 newHash) public {
        require(msg.sender == owner);
        secretHash = newHash;
    }
    // sha3(inputa) = 0x0232dh2o3842o834

    //frontRuning!! I am look at all the transactions that happen, and once i see yours i submit the same 
    //transactino with higher gas.
    //now the miners will mine my transaction first, and I will claim the bounty and reword before you.
    //and now your transaction won't work (because i changed the secret hash)
    // function guess(bytes32 _guess, bytes32 _newSecretHash) public {
    //     if(keccak256(abi.encodePacked(_guess)) == secretHash){
    //         owner = msg.sender;
    //         secretHash = _newSecretHash;
    //     }
    // }
    // commit- reveal scheme...
    //commit guess -> reveal

    //call this on block X
    function commitGuess(bytes32 _guessHash)public{
        guesses[msg.sender] = _guessHash;
    }
    //call this on lock >X
    function revealGuess(bytes32 _newSecretHash) public{
        if(keccak256(abi.encodePacked(guesses[msg.sender])) == secretHash){
            owner = msg.sender;
            secretHash = _newSecretHash;
        }
    }

    function enroll() public payable{
        balances[msg.sender] += msg.value;
    }

    function getBalance() public view returns(uint){
        return balances[msg.sender];
    }
    
    function withdraw() public {
        require(balances[msg.sender] > 0);
        uint balance = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(balance);
    }

    //front-running and miner manipulation.
    function getRandomNumber() public view returns(uint){
        return block.timestamp % 2;
    }
    //miner maipulation... a miner can set their own timestamp.
    // timestamp ruls for miners: can;t be in the past, and can;t be too far in the future....
    //timesdtamp % 2 all the miner needs to do is in the worst case increment timestamp by 1.
    function doubleOrNothing() public payable {// I send money
        require(msg.value > 0);
        if(block.timestamp % 2 == 0){
            msg.sender.transfer(msg.value * 2);
        }
    }
        
}
//solidity is easy to 

//1000 people

// logic flow
// create a new contract => 
// user1 = 0x001
// user2 = 0x002

// user2 => enroll(200000 wei)
// user2 => getBalance() => 2000000
// user2 => withdraw()
// user2 => getBalance() => 0
