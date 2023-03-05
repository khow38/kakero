// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

/* Errors */
error Betting__ExecuteNotNeeded(uint256 currentBalance, uint256 numPlayers, bool gameFinished);
error Betting__TransferFailed();
error Betting__SendMoreToEnterBetting();
error Betting__BettingNotOpen();

/**@title A sample Betting Contract
 * @author Yakou Hikoichi
 * * @notice This contract is for creating a sample betting contract
*/
contract Betting {

    // Betting Variables
    uint256 private immutable i_interval;

    uint256 private minimumBet;
    uint256 private totalBetOne;
    uint256 private totalBetTwo;
    uint256 private s_lastTimeStamp;

    address payable public owner;
    address private admin;
    bool public gameFinished;

    struct Player {
        uint256 amountBet;
        uint16 teamSelected;
    }
    // Address of the player and => the user info
    mapping(address => Player) public playerInfo;
    address payable[] public players;
    address payable[] private winners;

    /* Events */
    event BettingEnter(address indexed player);

    /* Functions */
    constructor(
      uint256 interval,
      uint256 entranceFee
    ) {
        i_interval = interval;
        minimumBet = entranceFee;         // 0.01 etherium
        gameFinished = false;
        s_lastTimeStamp = block.timestamp;
        admin = msg.sender;
        owner = payable(admin);
    }

    function betting(uint16 _teamSelected) public payable {
        //The first require is used to check if the player already exist
        require(!checkPlayerExists(msg.sender));
        require(!gameFinished);
        if (msg.value < minimumBet) {
            revert Betting__SendMoreToEnterBetting();
        }
        //We set the player informations : amount of the bet and selected team
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].teamSelected = _teamSelected;

        //then we add the address of the player to the players array
        players.push(payable(msg.sender));

        //at the end, we increment the stakes of the team selected with the player bet
        if ( _teamSelected == 1){
            totalBetOne += msg.value;
        }
        else{
            totalBetTwo += msg.value;
        }
        emit BettingEnter(msg.sender);
    }

    function distributePrizes(uint16 teamWinner) internal onlyAdmin {

        uint256 LoserBet = 0; //This will take the value of all losers bet
        uint256 WinnerBet = 0; //This will take the value of all winners bet
        address add;
        uint256 bet;
        address payable playerAddress;
        //We loop through the player array to check who selected the winner team
        for(uint256 i = 0; i < players.length; i++){
            playerAddress = players[i];
            //If the player selected the winner team
            //We add his address to the winners array
            if(playerInfo[playerAddress].teamSelected == teamWinner){
                winners.push(playerAddress);
            }
        }
        //We define which bet sum is the Loser one and which one is the winner
        if ( teamWinner == 1){
            LoserBet = totalBetTwo;
            WinnerBet = totalBetOne;
        }
        else{
            LoserBet = totalBetOne;
            WinnerBet = totalBetTwo;
        }
        //We loop through the array of winners, to give ethers to the winners
        for(uint256 j = 0; j < winners.length; j++){
            add = winners[j];
            bet = playerInfo[add].amountBet;
            uint256 prize = (bet*(10000+(LoserBet*10000/WinnerBet)))/10000;
            //Transfer the money to the user
            payable(winners[j]).transfer(prize);
        }
        owner.transfer(address(this).balance);

        gameFinished = true;
        // Delete all the players
        for (uint256 i = 0; i < players.length; i++){
            delete playerInfo[players[i]];
        }
        delete players; // Delete all the players array
        delete winners; // Delete all the winners array
        // players.length = 0; // Delete all the players array
        LoserBet = 0; //reinitialize the bets
        WinnerBet = 0;
        totalBetOne = 0;
        totalBetTwo = 0;
    }

    /**
     * @dev This is the function whether the execution of betting is ready or not
     * they look for `readyToExecute` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between betting runs.
     * 2. The Game is open.
     * 3. The contract has ETH.
     */
    function checkExecuteReady()
        public
        view
        returns (
            bool readyToExecute,
            bytes memory /* performData */
        )
    {
        bool isOpen = gameFinished == false;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = players.length > 0;
        bool hasBalance = address(this).balance > 0;
        readyToExecute = (timePassed && isOpen && hasBalance && hasPlayers);
        return (readyToExecute, "0x0"); // can we comment this out?
    }

    /**
     * @dev Once `checkExecuteReady` is returning `true`, this function is called
     * and it kicks off the winner.
     */
    function performExecute(
        uint16 oraclemsg
    ) external onlyAdmin{
        (bool readyToExecute, ) = checkExecuteReady();
        // require(upkeepNeeded, "Upkeep not needed");
        if (!readyToExecute) {
            revert Betting__ExecuteNotNeeded(
                address(this).balance,
                players.length,
                gameFinished
            );
        }
        // oracle engaged and redistribution of asset happens
        distributePrizes(oraclemsg);
    }


    /** Getter Functions */

    function getAdmin() public view returns (address) {
        return admin;
    }

    function reopenGame() public onlyAdmin{
        gameFinished = false;
        players = new address payable [](0);
        s_lastTimeStamp = block.timestamp;
    }

    function getGameFinished() public view returns (bool) {
        return gameFinished;
    }

    function checkPlayerExists(address player) public view returns (bool) {
      uint256 l = players.length;
      for(uint256 i = 0; i < l; i++){
         if(players[i] == player) return true;
      }
      return false;
    }

    function AmountOne() public view returns(uint256){
       return totalBetOne;
    }

    function AmountTwo() public view returns(uint256){
       return totalBetTwo;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return players[index];
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    function getEntranceFee() public view returns (uint256) {
        return minimumBet;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return players.length;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
