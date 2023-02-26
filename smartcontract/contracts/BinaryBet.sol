// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

/* Errors */
error Betting__ExecuteNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 bettingState);
error Betting__TransferFailed();
error Betting__SendMoreToEnterBetting();
error Betting__BettingNotOpen();

/**@title A sample Betting Contract
 * @author Yakou Hikoichi
 * * @notice This contract is for creating a sample betting contract
*/
contract Betting {
    /* Type declarations */
    enum BettingState {
        OPEN,
        CALCULATING,
        FINISHED
    }
    /* State variables */

    // Betting Variables
    uint256 private immutable i_interval;
    uint32 private immutable i_callbackGasLimit;

    uint256 private minimumBet;
    uint256 private totalBetOne;
    uint256 private totalBetTwo;
    uint256 private s_lastTimeStamp;

    address private admin;
    address payable[] private players;
    BettingState private s_bettingState;

    struct Player {
        uint256 amountBet;
        uint16  teamSelected;
    }
    // Address of the player and => the user info
    mapping(address => Player) public playerInfo;


    /* Events */
    event BettingEnter(address indexed player);

    /* Functions */
    constructor(
      uint256 interval,
      uint256 entranceFee,
      uint32 callbackGasLimit
    ) {
        i_interval = interval;
        minimumBet = entranceFee;         // 0.01 etherium
        s_bettingState = BettingState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_callbackGasLimit = callbackGasLimit;
        admin = msg.sender;
    }

    function betting(uint16 _teamSelected) public payable {
        //The first require is used to check if the player already exist
        require(!checkPlayerExists(msg.sender));

        if (msg.value < minimumBet) {
            revert Betting__SendMoreToEnterBetting();
        }
        if (s_bettingState != BettingState.OPEN) {
            revert Betting__BettingNotOpen();
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

    function distributePrizes(uint16 teamWinner) public {
        address payable[] memory winners;
        uint256 count = 0; // This is the count for the array of winners
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
                winners[count] = playerAddress;
                count++;
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
        for(uint256 j = 0; j < count; j++){
            // Check that the address in this fixed array is not empty
            if(winners[j] != address(0)) {
                add = winners[j];
                bet = playerInfo[add].amountBet;
                //Transfer the money to the user
                winners[j].transfer((bet*(10000+(LoserBet*10000/WinnerBet)))/10000 );
            }
        }

        s_bettingState = BettingState.FINISHED;
        delete playerInfo[playerAddress]; // Delete all the players
        delete players; // Delete all the players array
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
        bool isOpen = BettingState.OPEN == s_bettingState;
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
                uint256(s_bettingState)
            );
        }
        s_bettingState = BettingState.CALCULATING;
        // oracle engaged and redistribution of asset happens
        distributePrizes(oraclemsg);
        players = new address payable[](0);

        s_bettingState = BettingState.FINISHED;
    }


    /** Getter Functions */

    function getAdmin() public view returns (address) {
        return admin;
    }

    function reopenGame() public onlyAdmin{
        s_bettingState = BettingState.OPEN;
        players = new address payable [](0);
        s_lastTimeStamp = block.timestamp;
    }

    function getBettingState() public view returns (BettingState) {
        return s_bettingState;
    }

    function checkPlayerExists(address player) public view returns (bool) {
      uint256 l = players.length
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
}
