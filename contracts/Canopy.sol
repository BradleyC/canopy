pragma solidity ^0.4.24;

contract Canopy {

    /*** DATA HANDLING ***/
    struct Post {
        string title;
        address posterAddress;
        string url;
        uint timePosted;
        uint stake;
        uint voteValue;
        uint valuePositive;
        uint valueNegative;
        uint valueWeight;
        bool active;
    }

}