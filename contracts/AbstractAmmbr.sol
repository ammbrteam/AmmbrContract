pragma solidity ^0.4.11;
import './Ownable.sol';


contract AbstractAmmbr is Ownable{ 

    bool public mintingFinished = false;
    
      modifier canMint() {
         require(!mintingFinished);
    _;
    
    }
  
   function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool){
       
   }
}
