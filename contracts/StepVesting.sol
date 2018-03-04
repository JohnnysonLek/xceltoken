pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol';
import 'zeppelin-solidity/contracts/examples/SimpleToken.sol';


contract StepVesting is TokenVesting {

/**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   * @param _cliffPeriod duration in seconds of cliff period in which the cliff will vest til next pe
   * @param _numberOfPartitions number of partitions in which duration less cliff period is divided (from 1 - 8 max)
   */

    /*
    *sample:
    *_cliffPeriod = 2592000; // ~30dys
    *_numberOfPartitions = 8; // eight months
    */

    uint256 public cliffPercent;

    //uint8 constant stepVestingDuration= 2592000  //30*24*60*60
    uint256 public stepVestingPercent;

    uint256 public numberOfPartitions;

    uint256 public stepVestingDuration;



    // function StepVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _cliffPercent, uint256 _stepVestingPercent,uint256 _numberOfPartitions, uint256 _stepVestingDuration, bool _revocable) TokenVesting(_beneficiary, _start, _cliff, stepVestingDuration * numberOfPartitions, _revocable) public {
    function StepVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _cliffPercent, uint256 _stepVestingPercent, uint256 _numberOfPartitions, uint256 _stepVestingDuration, uint256 _duration, bool _revocable) TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable) public {

        cliffPercent = _cliffPercent;
        stepVestingPercent = _stepVestingPercent;
        numberOfPartitions = _numberOfPartitions;
        stepVestingDuration = _stepVestingDuration;

        /*
        stepVestingPercent = _stepVestingPercent;
        numberOfPartitions = _numberOfPartitions;
        if(cliffPercent + (stepVestingPercent * numberOfPartitions) != 100){
          revert();
        }
        */
    }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */

    function vestedAmount(ERC20Basic token) public constant returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (now < cliff) {
            return 0;
        } else if (now >= start.add(duration) || revoked[token]) {
            return totalBalance;
        } else if (now >= cliff && now < cliff.add(stepVestingDuration) ) {
            return totalBalance.mul(cliffPercent).div(100);
        } else {
              //add cliff% plus vesting as per no of stepVestingDuration.  / should just give the
              //quotient of devision
             uint256 vestingPercentage = cliffPercent + ((now - start)/stepVestingDuration) * stepVestingPercent;
             return totalBalance.mul(vestingPercentage).div(100);
         }
      }

}